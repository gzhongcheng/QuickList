# 获取项目的XcodeSetting并输出到tempBuildSetting.txt文件中
function startGetXcodeSettings()
{
    xcodebuild -workspace "${WORKSPACE_NAME}" -scheme "${PROJECT_NAME}" -showBuildSettings > tempBuildSetting.txt
}

# 获取tempBuildSetting.txt文件中的XcodeSetting中指定key的值
function getXcodeSetting()
{
    row=`sed -n /" ${1} = "/= tempBuildSetting.txt`
    map=`sed -n ${row}p tempBuildSetting.txt`
    array=(${map// = / })
    unset array[0]
    value=${array[@]}
    echo $value
}

# 结束获取，移除tempBuildSetting.txt文件
function finishGetXcodeSettings() {
    rm -f tempBuildSetting.txt
}

# 用法：
# startGetXcodeSettings
# SYMROOT=`getXcodeSetting "SYMROOT"`
# ARCHS_STANDARD=`getXcodeSetting "ARCHS_STANDARD"`
# echo $SYMROOT
# echo $ARCHS_STANDARD
# finishGetXcodeSettings

