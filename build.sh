#!/bin/bash


# Clone libufdt if doesnt exist
if [ -f "./libufdt/Android.bp" ]; then
    echo INFO: libufdt found
else
    echo WORK: Cloning libufdt
    git clone https://android.googlesource.com/platform/system/libufdt
fi

PATH="$(pwd)/../neutron-clang/bin:$PATH"
KBUILD_COMPILER_STRING="$($(pwd)/../neutron-clang/bin/clang --version | head -n 1 | perl -pe 's/\((?:http|git).*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"


export PATH
export KBUILD_COMPILER_STRING


# Compile the kernel
kmake() {
    make -j"$(nproc --all)" \
	ARCH=arm64 \
    CC="ccache clang" \
    LD="ccache ld.lld" \
    CXX="ccache clang++" \
    AR="ccache llvm-ar" \
    AS="ccache llvm-as" \
    NM="ccache llvm-nm" \
    STRIP="ccache llvm-strip" \
    OBJCOPY="ccache llvm-objcopy" \
    OBJDUMP="ccache llvm-objdump"\
    OBJSIZE="ccache llvm-size" \
    READELF="ccache llvm-readelf" \
    HOSTCC="ccache clang" \
    HOSTCXX="ccache clang++" \
    HOSTAR="ccache llvm-ar" \
    HOSTAS="ccache llvm-as" \
    HOSTNM="ccache llvm-nm" \
    HOSTLD="ccache ld.lld" \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    $@
}

dtmake() {
python2 libufdt/utils/src/mkdtboimg.py cfg_create \
    out/arch/arm64/boot/dts/dtbo.img \
    --dtb-dir out/arch/arm64/boot/dts/samsung build/r7.cfg
python2 libufdt/utils/src/mkdtboimg.py cfg_create \
    out/arch/arm64/boot/dts/dtb.img \
    --dtb-dir out/arch/arm64/boot/dts/exynos build/exynos9810.cfg
}

pack() {
    cp out/arch/arm64/boot/dts/dtbo.img AnyKernel/
    cp out/arch/arm64/boot/dts/dtb.img AnyKernel/
    cp out/arch/arm64/boot/Image AnyKernel/
    cd AnyKernel
    zip -r9 $1 *
    cd ..
    mv AnyKernel/$1 ./out/
}

# Export shell functions
export kmake
#export dtmake
export pack
