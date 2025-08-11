#!/bin/bash
#ubuntu版本,可选值18.04 20.04 22.04 24.04 
UBUNTU_VERSION=22.04

#内核源码
KERNEL_SOURCE=https://github.com/MiCode/Xiaomi_Kernel_OpenSource/
#分支
KERNEL_BRANCH=liuqin-t-oss
#内核配置文件
KERNEL_CONFIG=gki_defconfig
#架构
ARCH=arm64

#KernelSU可选的值 kernelsu kernelsu-next suki-su
KERNEL_SU=kernelsu


#启用LXC-Docker支持
ENABLE_LXC=true



#额外附加的编译命令(传递到make)
EXTRA_CMDS="LLVM=1 LLVM_IAS=1 AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf OBJSIZE=llvm-size STRIP=llvm-strip"

#使用magiskboot打包内核(默认使用Anykernel3打包，若启用则同时使用anykernel3和magiskboot打包内核，并上传工件)
USE_MAGISKBOOT=true

# 编译工具链（若留空则默认clang，可选 gcc）
TOOLCHAIN=clang
# 工具链版本（若留空则clang默认 r383902b，gcc 默认 4.9）
CLANG_VERSION=r450784b
GCC_VERSION=
#目前CLANG_VERSION的可取值(只填写 r-xxxxx部分)
#clang-r383902b
#clang-r365631c1
#clang-r370808
#clang-r370808b 
#clang-r377782b
#clang-r377782c
#clang-r377782d 
#clang-r383902 
#clang-r383902b 
#clang-r383902b1 
#clang-r383902c 
#clang-r399163 
#clang-r399163b 
#clang-r407598b 
#clang-r412851 
#clang-r416183 
#clang-r416183b 
#clang-r416183c
#clang-r416183b1
#clang-r428724
#clang-r433403
#clang-r433403b
#clang-r437112
#clang-r437112b 
#clang-r445002 
#clang-r450784 
#clang-r450784b 
#clang-r450784c 
#clang-r450784d 
#clang-r450784e 
#clang-r458507 
#clang-r468909 
#clang-r468909b 
#clang-r475365b 
#clang-r487747 
#clang-r487747b 
#clang-r487747c
#clang-r498229 
#clang-r498229b 
#clang-r510928
#clang-r522817 
#clang-r530567 
#clang-r536225 
#clang-r547379 






##以下几乎不休改
sudo docker build . --file Dockerfile \
             --tag android-kernel-builder:latest \
             --build-arg UBUNTU_VERSION=${UBUNTU_VERSION} \
             --build-arg KERNEL_SOURCE=${KERNEL_SOURCE} \
             --build-arg KERNEL_BRANCH=${KERNEL_BRANCH} \
             --build-arg ARCH=${ARCH}  \
             --build-arg KERNEL_SU=${KERNEL_SU} \
             --build-arg ENABLE_LXC=${ENABLE_LXC} \
             --build-arg TOOLCHAIN=${TOOLCHAIN} \
             --build-arg CLANG_VERSION=${CLANG_VERSION} \
             --build-arg GCC_VERSION=${GCC_VERSION} \
             --build-arg EXTRA_CMDS=${EXTRA_CMDS} \
             --build-arg USE_MAGISKBOOT=${USE_MAGISKBOOT} 
             
          
sudo docker run -v $GITHUB_WORKSPACE/kernel_workspace:/root/output android-kernel-builder:latest



      
