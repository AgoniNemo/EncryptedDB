#!/usr/bin/env bash


target_path="./Example"

target_name="EncryptedDB"
framework_name=${target_name}
configuration="Release"
iphonesimulator=""
iphones=""


xcodebuild clean -workspace ${target_path}/${target_name}.xcworkspace -scheme ${target_name} -configuration ${configuration}

function getPath() {
    is_mulator=$1
    sdkStr="iphonesimulator"
    valid=`ARCHS="x86_64" VALID_ARCHS="x86_64"`
    if [ $is_mulator == true ]
    then
        echo "########## 模拟器导出中 ##########"
    else
        sdkStr="iphoneos"
        valid=`ARCHS="arm64" VALID_ARCHS="arm64"`
        echo "########## 真机导出中 ##########"
    fi

    echo "########## 导出命令 ##########"

    echo "xcodebuild -workspace ${target_path}/${target_name}.xcworkspace -scheme ${target_name} -sdk ${sdkStr} -configuration ${configuration} ${valid}"

    mulator_framework_result=$(xcodebuild -workspace ${target_path}/${target_name}.xcworkspace -scheme ${target_name} -sdk ${sdkStr} -configuration ${configuration} ${valid} | grep "Release-${sdkStr}/${framework_name}.framework")

    mulator_framework_path=$(echo ${mulator_framework_result} | awk -F " " '{print $NF}')

    echo "########## 导出${sdkStr}路径：${mulator_framework_path}"

    if [ $is_mulator == true ]
    then
        iphonesimulator=$mulator_framework_path
    else
        iphones=$mulator_framework_path
    fi
}

exportSDKPath=${framework_name}/Products

getPath true

if [ $iphonesimulator ]; then
    echo "########## 模拟机包导出路径：${iphonesimulator}/${target_name}";
fi

cp -R ${iphonesimulator} ${exportSDKPath}

echo "########## 模拟机包架构 ##########"
lipo -info ${iphonesimulator}/${target_name}


getPath false

if [ ! -d $exportSDKPath ]; then
    mkdir -p $exportSDKPath;
fi

cp -R ${iphones} ${exportSDKPath}/iphones_${target_name}.framework

echo "########## 真机包包架构 ##########"
lipo -info ${iphones}/${target_name}

if [ $iphones ]; then
    echo "########## 真机包导出路径：${exportSDKPath}";
fi


#lipo -create ${iphonesimulator}/${target_name} ${exportSDKPath}/${framework_name}.framework/${target_name} -output ${exportSDKPath}/${framework_name}.framework/${target_name}


# xcodebuild -workspace ./Example/EncryptedDB.xcworkspace -scheme EncryptedDB -sdk iphonesimulator -configuration Release