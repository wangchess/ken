# 基础镜像
ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION} 

# 维护者信息
LABEL maintainer="Android Kernel Builder by tomxi1997"
LABEL description="Docker image for building Android kernels with aosp clang/gcc"

# 构建时变量（可通过 --build-arg 传入）
# 内核源码地址（默认使用谷歌安卓内核示例）
ARG KERNEL_SOURCE=https://github.com/LineageOS/android_kernel_xiaomi_msm8998
# 内核分支（默认安卓通用内核 5.4 分支）
ARG KERNEL_BRANCH=lineage-22.2
# 架构（默认 arm64）
ARG ARCH=arm64
# 内核配置文件
ARG KERNEL_CONFIG=chiron_defconfig

#KernelSU可选的值 kernelsu kernelsu-next suki-su
ARG KERNEL_SU=kernelsu-next                                                                               

#启用LXC-Docker支持
ARG ENABLE_LXC=true

#额外编译命令
ARG EXTRA_CMDS="LLVM=1 LLVM_IAS=1 AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf OBJSIZE=llvm-size STRIP=llvm-strip"                                                   

#使用magiskboot打包内核
ARG USE_MAGISKBOOT=true




# 工具链版本（clang 默认 r383902b，gcc 默认 4.9）
ARG CLANG_BRANCH=android11-release 
ARG CLANG_VERSION=r383902b
ARG GCC_VERSION=
# 环境变量（容器内可见，用于编译过程）
ENV DEBIAN_FRONTEND=noninteractive \
    KERNEL_DIR=/root/kernel \
    TOOLCHAIN_DIR=/root/toolchain \
    OUTPUT_DIR=/root/output \
    TMP_DIR=/root/output/tmp 
RUN apt-get install wget
    
# 安装基础依赖
RUN apt-get update && apt-get install -y \
    # 基础工具
    git curl wget ca-certificates \
    # 编译依赖
    build-essential flex bison libssl-dev libelf-dev \
    bc dwarves zstd lz4 cpio libncurses5-dev \
    # 多架构支持
    crossbuild-essential-arm64 crossbuild-essential-armhf \
    # 其他工具
    python3 python3-pip device-tree-compiler && \
    # 清理缓存，减小镜像体积
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 创建工作目录
RUN mkdir -p ${KERNEL_DIR} ${TOOLCHAIN_DIR} ${TOOLCHAIN_DIR}/gcc64 ${TOOLCHAIN_DIR}/gcc32 ${OUTPUT_DIR} ${TMP_DIR}

# 下载编译工具链

        # 下载 clang 工具链（安卓官方推荐版本） \
       # git clone --depth=1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 -b ${CLANG_BRANCH} ${TOOLCHAIN_DIR}; \
        # 下载配套的 gcc 工具链（用于链接等步骤） \
        wget https://gitlab.com/tomxi1997/google_gcc-4.9/-/raw/main/arm-linux-androideabi-4.9.tar.xz
        git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 -b ${CLANG_BRANCH} --depth=1 ${TOOLCHAIN_DIR}
        tar -xf arm-linux-androideabi-4.9.tar.xz -C ${TOOLCHAIN_DIR}/gcc32
        wget https://gitlab.com/tomxi1997/google_gcc-4.9/-/raw/main/aarch64-linux-android-4.9.tar.xz
        tar -xf aarch64-linux-android-4.9.tar.xz -C ${TOOLCHAIN_DIR}/gcc64
        rm *.xz

# 下载内核源码
ENV PATH="${TOOLCHAIN_DIR}/clang-${CLANG_VERSION}/bin:${TOOLCHAIN_DIR}/gcc64/bin:${TOOLCHAIN_DIR}/gcc32/bin:${PATH}"
RUN git clone --depth=1 -b ${KERNEL_BRANCH} ${KERNEL_SOURCE} ${KERNEL_DIR}

# 复制编译脚本（后续通过容器内脚本执行编译）
COPY build_kernel.sh /root/build_kernel.sh
COPY bin/magiskboot /root/output/tmp/magiskboot
COPY boot/boot.img /root/output/tmp/boot.img
RUN chmod 755 /root/build_kernel.sh /root/output/tmp/magiskboot


# 工作目录切换到内核源码目录
WORKDIR ${KERNEL_DIR}

# 容器启动时执行编译脚本
#CMD ["/root/build_kernel.sh"]
RUN bash /root/build_kernel.sh 
