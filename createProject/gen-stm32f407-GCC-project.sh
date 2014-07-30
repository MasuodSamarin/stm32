#!/bin/bash

BASEDIR=~/stm32
CMSIS=$BASEDIR/STM32F4-Discovery_FW_V1.0.0
MBED=$BASEDIR/mbed/libraries/mbed
MBEDRTOS=$BASEDIR/mbed/libraries/rtos
FREERTOS=$BASEDIR/FreeRTOS/FreeRTOS
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

do_create_dir()
{
mkdir -p $(pwd)/bin
mkdir -p $(pwd)/inc
mkdir -p $(pwd)/lib
mkdir -p $(pwd)/src
}

do_deploy_cmsis()
{
echo 1
}

do_deploy_mbed()
{
cp -sR $MBED $(pwd)/lib/mbed
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/mbed/targets/cmsis -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/cmsis/TARGET_STM -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM32F4XX' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/cmsis/TARGET_STM/TARGET_STM32F4XX -mindepth 1 -maxdepth 1 -type d -not -name 'TOOLCHAIN_GCC_ARM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/hal -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM' -exec rm -rf {} \;
find $(pwd)/lib/mbed/targets/hal/TARGET_STM -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_STM32F4XX' -exec rm -rf {} \;
# Linker script
ln -s lib/mbed/targets/cmsis/TARGET_STM/TARGET_STM32F4XX/TOOLCHAIN_GCC_ARM/STM32F407.ld stm32f407.ld
# Abs to Rel Symlinks
symlinks -rc $(pwd) 1>/dev/null
}

do_deploy_freertos()
{
cp -sR $FREERTOS $(pwd)/lib/FreeRTOS
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/FreeRTOS -mindepth 1 -maxdepth 1 -type d -not -name 'Source' -exec rm -rf {} \;
find $(pwd)/lib/FreeRTOS/Source/portable -mindepth 1 -maxdepth 1 -type d -not -name 'GCC' -not -name 'MemMang' -exec rm -rf {} \;
find $(pwd)/lib/FreeRTOS/Source/portable/MemMang/*.c -not -name 'heap_1.c' -exec rm -rf {} \;
find $(pwd)/lib/FreeRTOS/Source/portable/GCC -mindepth 1 -maxdepth 1 -type d -not -name 'ARM_CM4F' -exec rm -rf {} \;
# Copy FreeRTOSConfig.h
mkdir $(pwd)/lib/FreeRTOS/config/
cp $SCRIPTDIR/freertos/FreeRTOSConfig.h $(pwd)/lib/FreeRTOS/config/FreeRTOSConfig.h
# Abs to Rel Symlinks
symlinks -rc $(pwd) 1>/dev/null
}

do_deploy_mbedrots()
{
cp -sR $MBEDRTOS $(pwd)/lib/mbedrtos
# Prune targets not(STM32F4XX or GCC)
find $(pwd)/lib/mbedrtos/rtx -mindepth 1 -maxdepth 1 -type d -not -name 'TARGET_M4' -exec rm -rf {} \;
find $(pwd)/lib/mbedrtos/rtx/TARGET_M4 -mindepth 1 -maxdepth 1 -type d -not -name 'TOOLCHAIN_GCC' -exec rm -rf {} \;
# Abs to Rel Symlinks
symlinks -rc $(pwd) 1>/dev/null
}

case "$1" in
  cmsis-none)
	;;
  cmsis-none-lib)
	;;
  cmsis-freertos)
	;;
  cmsis-freertos-lib)
	;;
  mbed-none)
	do_create_dir
	do_deploy_mbed
	cp $SCRIPTDIR/mbed-none/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none/Makefile $(pwd)/Makefile
	;;
  mbed-none-lib)
	do_create_dir
	do_deploy_mbed
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	cp $SCRIPTDIR/mbed-none/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-none/Makefile-lib $(pwd)/Makefile
	;;
  mbed-freertos)
	do_create_dir
	do_deploy_mbed
	do_deploy_freertos
	cp $SCRIPTDIR/mbed-freertos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-freertos/Makefile $(pwd)/Makefile
	;;
  mbed-freertos-lib)
	do_create_dir
	do_deploy_mbed
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	do_deploy_freertos
	cp $SCRIPTDIR/freertos/Makefile-lib $(pwd)/lib/FreeRTOS/Makefile
	cp $SCRIPTDIR/mbed-freertos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-freertos/Makefile-lib $(pwd)/Makefile
	;;
  mbed-mbedrtos)
	do_create_dir
	do_deploy_mbed
	do_deploy_mbedrots
	cp $SCRIPTDIR/mbed-mbedrtos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-mbedrtos/Makefile $(pwd)/Makefile
	;;
  mbed-mbedrtos-lib)
	do_create_dir
	do_deploy_mbed
	cp $SCRIPTDIR/mbed/Makefile-lib $(pwd)/lib/mbed/Makefile
	do_deploy_mbedrots
	cp $SCRIPTDIR/mbedrtos/Makefile-lib $(pwd)/lib/mbedrtos/Makefile
	cp $SCRIPTDIR/mbed-mbedrtos/main.cpp $(pwd)/src/main.cpp
	cp $SCRIPTDIR/mbed-mbedrtos/Makefile-lib $(pwd)/Makefile
	;;
  *)
	echo "Usage: $SCRIPTNAME {cmsis-none|cmsis-none-lib|cmsis-freertos|cmsis-freertos-lib|mbed-none|mbed-none-lib|mbed-freertos|mbed-freertos-lib|mbed-mbedrtos|mbed-mbedrtos-lib}" >&2
	exit 3
	;;
esac
