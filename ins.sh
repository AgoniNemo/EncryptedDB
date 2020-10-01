#!/bin/bash

#要build的target名:xxx代表你sdk的姓名target名字
target_Name="EncryptedDB"

#编译模式  Release、Debug
build_model=Release

#获取工程当前所在路径
project_path=$(pwd)

#编译文件路径
buildPath=${project_path}/build

#导出sdk地址
exportSdkPath=${project_path}/EncryptedDB/Products/${target_Name}-SDK/${build_model}

if [ ! -d $exportSdkPath ]; then
mkdir -p $exportSdkPath;
fi

#真机sdk路径
iphoneos_path=${buildPath}/${build_model}-iphoneos/${target_Name}.framework/${target_Name}
#模拟器sdk路径
simulator_path=${buildPath}/${build_model}-iphonesimulator/${target_Name}.framework/${target_Name}
#合并后sdk路径
merge_path=${exportSdkPath}/${target_Name}.framework/${target_Name}

#build之前clean一下
xcodebuild -target ${target_Name} clean

echo "########## 编译路径：${target_Name}"
echo "########## 编译路径1：${build_model}"
echo "########## 编译路径2：${project_path}"
echo "########## 编译路径3：${buildPath}"
echo "########## 编译路径4：${iphoneos_path}"
echo "########## 编译路径5：${simulator_path}"
echo "########## 编译路径6：${merge_path}"
echo "########## 编译路径7：${exportSdkPath}"

#模拟器build
xcodebuild -target ${target_Name} -configuration ${build_model} -sdk iphonesimulator ARCHS="x86_64" VALID_ARCHS="x86_64"
echo "############################ iphonesimulator 编译成功 ##########################"

#真机build
xcodebuild -target ${target_Name} -configuration ${build_model} -sdk iphoneos "ARCHS=arm64" "VALID_ARCHS=arm64"
echo "############################  真机编译成功 ##########################"

#复制真机.framework到目标文件夹
cp -R ${buildPath}/${build_model}-iphoneos/${target_Name}.framework ${exportSdkPath}

#合并模拟器和真机.a包
lipo -create ${iphoneos_path} ${simulator_path} -output ${merge_path}

#删除framework下的Info.plist
rm -r -f ${exportSdkPath}/${target_Name}.framework/Info.plist

#删除framework下的Modules
rm -r -f ${exportSdkPath}/${target_Name}.framework/Modules
#删除多余的文件
rm -rf ${exportSdkPath}/${target_Name}.framework/PassGuardCtrlBundle.bundle
rm -rf ${exportSdkPath}/${target_Name}.framework/JKKeyboardManager.bundle
rm -rf ${exportSdkPath}/${target_Name}.framework/MJRefresh.bundle
rm -rf ${exportSdkPath}/${target_Name}.framework/LICENSE
#压缩合并后的文件

#压缩后的文件名
package_date=`date '+%Y-%m-%d日%X'`
sdk_zip_name=lib${target_Name}_${build_model}_${package_date}.zip
#跳转到sdk的输出路径
cd ${exportSdkPath}
#压缩sdk输出路径下的所有文件
zip -r ~/Desktop/${target_Name}-SDK/${sdk_zip_name} ./*

#打开合并后的sdk所在路径
open ${exportSdkPath}

#删除build文件
if [ -d ${buildPath} ]; then
rm -rf ${buildPath}
echo "########################## 删除build文件 #########################"
fi
