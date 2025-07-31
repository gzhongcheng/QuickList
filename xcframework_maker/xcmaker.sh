# 模拟器x86_64 Framework包路径 必须要支持x86_64
simulator86FrameworkPath=$1
# 真机Framework包路径 必须要支持arm64
iphoneosFrameworkPath=$2
# 输出路径
outputPath=$3
# 模块名称
projectName=$4

# 输出的xcframework名称
XCFrameworkPath="${outputPath}/${projectName}.xcframework"
# 创建xcframework文件
mkdir -p $XCFrameworkPath
rm -drf $XCFrameworkPath

# 复制模拟器的Framework
mkdir -p "$XCFrameworkPath/ios-x86_64-simulator"
cp -R $simulator86FrameworkPath "$XCFrameworkPath/ios-x86_64-simulator"

# 复制真机的Framework
mkdir -p "$XCFrameworkPath/ios-arm64"
cp -R $iphoneosFrameworkPath "$XCFrameworkPath/ios-arm64"

# 复制.plist模板
cp -R xcframework_maker/Info.plist $XCFrameworkPath
sed -i ".bak" "s/#NAME/$projectName/g" "$XCFrameworkPath/Info.plist"
rm -f "$XCFrameworkPath/Info.plist.bak"
