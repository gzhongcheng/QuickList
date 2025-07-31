source getXcodeSetting.sh

# 打包framework脚本
echo "运行此脚本前，请先将Package-Project工程编译一遍，确保所有相关文件以已导入且正常运行，没有报错"
echo "======开始打包Framework======"

#工程名
PROJECT_NAME=MTEList
WORKSPACE_NAME=${PROJECT_NAME}.xcworkspace

#工程路径
PROJECT_DIR="Example/"

#打包模式 Debug/Release 默认是Release
development_mode=Release

# 输出文件夹
UNIVERSAL_OUTPUTFOLDER="${PROJECT_NAME}/PackageFramework/"
INSTALL_DIR_A=${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.xcframework/ios-arm64/${PROJECT_NAME}.framework/${PROJECT_NAME}

# 清空输出文件夹
rm -drf "${UNIVERSAL_OUTPUTFOLDER}"
# 确保输出文件夹存在
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

#build之后的文件夹路径
cd ${PROJECT_DIR}
startGetXcodeSettings
BUILD_DIR=`getXcodeSetting "SYMROOT"`
finishGetXcodeSettings
cd ../

echo "build文件夹${BUILD_DIR}"

echo "======Step 1. clean======"
cd ${PROJECT_DIR}
xcodebuild -workspace "${WORKSPACE_NAME}" -scheme "${PROJECT_NAME}" -configuration ${development_mode} clean
pod update --no-repo-update
cd ../

# 获取项目的XcodeSetting并输出到tempBuildSetting.txt文件中
function getBuildState()
{
    if [ `grep -c "BUILD SUCCEEDED" buildLog.txt` -ne '0' ];then
        echo "${1}编译成功！"
    else
        echo "${1}编译失败，请检查编译日志！"
        open buildLog.txt
        exit 0
    fi
}


echo "======Step 2. build 真机版本======"
xcodebuild -workspace "${PROJECT_DIR}/${WORKSPACE_NAME}" -scheme "${PROJECT_NAME}" -configuration ${development_mode} -sdk iphoneos ONLY_ACTIVE_ARCH=YES -arch arm64 build > buildLog.txt
getBuildState "真机版本"

echo "======Step 3. build 模拟器版本(模拟器版本仅编译x86_64和arm64)======"
# x86_64
xcodebuild -workspace "${PROJECT_DIR}/${WORKSPACE_NAME}" -scheme "${PROJECT_NAME}" -configuration ${development_mode} -sdk iphonesimulator ONLY_ACTIVE_ARCH=YES -arch x86_64 build > buildLog.txt
getBuildState "模拟器x86_64版本"

# 删除log
rm -f buildLog.txt

# -f 判断文件是否存在
if [ -f "${BUILD_DIR}/${development_mode}-iphoneos/${PROJECT_NAME}/${PROJECT_NAME}.framework/${PROJECT_NAME}" ]
then
    echo "======生成xcframework"
    sh xcframework_maker/xcmaker.sh "${BUILD_DIR}/${development_mode}-iphonesimulator/${PROJECT_NAME}/${PROJECT_NAME}.framework" "${BUILD_DIR}/${development_mode}-iphoneos/${PROJECT_NAME}/${PROJECT_NAME}.framework" $UNIVERSAL_OUTPUTFOLDER $PROJECT_NAME
    echo "======生成xcframework结束======"

    # -f 判断文件是否存在
    if [ -f "${INSTALL_DIR_A}" ]
    then
        echo "======验证合成包是否成功======"
        lipo -info "${INSTALL_DIR_A}"
        echo "======合成包成功,即将打开文件夹======"
        #打开目标文件夹
        open "${UNIVERSAL_OUTPUTFOLDER}"
    else
        echo "============================================================"
        echo "打包xcframework失败,请检查！"
        echo "Example的podfile中的必须使用 ${PROJECT_NAME}/File 或其他方式进行源码引用"
        echo "============================================================"
    fi
else
    echo "============================================================"
    echo "打包xcframework失败,请检查！"
    echo "Example的podfile中的必须使用 ${PROJECT_NAME}/File 或其他方式进行源码引用"
    echo "============================================================"
fi
