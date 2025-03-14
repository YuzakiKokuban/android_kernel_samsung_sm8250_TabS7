alias python=python2
export PATH="/usr/local/python2.7/bin:$PATH"
python --version
#!/usr/bin/env python2
export PATH="/home/kokuban/PlentyofToolchain/toolchaintabs7/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9-lineage-19.1/bin:/home/kokuban/PlentyofToolchain/toolchaintabs7/llvm-arm-toolchain-ship-10.0-master/bin:/home/kokuban/PlentyofToolchain/toolchaintabs7/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9-lineage-19.1/bin:usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/snap/bin:$PATH"
echo $PATH

set -e

TARGET_DEFCONFIG=${1:-gts7xl_eur_openx_defconfig}

cd "$(dirname "$0")"

LOCALVERSION=-Kokuban-Hua-S5DXA1

if [ "$LTO" == "thin" ]; then
  LOCALVERSION+="-thin"
fi

ARGS="
O=out
ARCH=arm64
CLANG_TRIPLE=aarch64-linux-gnu-
CROSS_COMPILE=/home/kokuban/PlentyofToolchain/toolchaintabs7/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9-lineage-19.1/bin/aarch64-linux-android-
CC=/home/kokuban/PlentyofToolchain/toolchaintabs7/llvm-arm-toolchain-ship-10.0-master/bin/clang
CROSS_COMPILE_COMPAT=/home/kokuban/PlentyofToolchain/toolchaintabs7/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9-lineage-19.1/bin/arm-linux-android-
LOCALVERSION=$LOCALVERSION
"

# build kernel
make -j$(nproc) -C $(pwd) O=$(pwd)/out DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y CLANG_TRIPLE=aarch64-linux-gnu- ${ARGS} $TARGET_DEFCONFIG

./scripts/config --file out/.config \
  -d UH \
  -d RKP \
  -d KDP \
  -d SECURITY_DEFEX \
  -d INTEGRITY \
  -d FIVE \
  -d TRIM_UNUSED_KSYMS \
  -d PROCA \
  -d PROCA_GKI_10 \
  -d PROCA_S_OS \
  -d PROCA_CERTIFICATES_XATTR \
  -d PROCA_CERT_ENG \
  -d PROCA_CERT_USER \
  -d GAF_V6 \
  -d FIVE \
  -d FIVE_CERT_USER \
  -d FIVE_DEFAULT_HASH

if [ "$LTO" = "thin" ]; then
  ./scripts/config --file out/.config -e LTO_CLANG_THIN -d LTO_CLANG_FULL
fi

make -j$(nproc) -C $(pwd) O=$(pwd)/out DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y CLANG_TRIPLE=aarch64-linux-gnu- ${ARGS}
 
cd out
if [ ! -d AnyKernel3 ]; then
  git clone --depth=1 https://github.com/YuzakiKokuban/AnyKernel3.git -b kona_tab
fi
cp arch/arm64/boot/Image AnyKernel3/zImage
name=TabS7_${TARGET_DEFCONFIG%%_defconfig}_kernel_`cat include/config/kernel.release`_`date '+%Y_%m_%d'`
cd AnyKernel3
zip -r ${name}.zip * -x *.zip
echo "AnyKernel3 package output to $(realpath $name).zip"
