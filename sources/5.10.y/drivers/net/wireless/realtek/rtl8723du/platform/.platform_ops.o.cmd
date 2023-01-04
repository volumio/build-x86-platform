cmd_drivers/net/wireless/rtl8723du/platform/platform_ops.o := ccache aarch64-linux-gnu-gcc -Wp,-MMD,drivers/net/wireless/rtl8723du/platform/.platform_ops.o.d  -nostdinc -isystem /home/gkkpch/armbian-volumio/cache/toolchain/gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu/bin/../lib/gcc/aarch64-linux-gnu/8.3.0/include -I./arch/arm64/include -I./arch/arm64/include/generated  -I./include -I./arch/arm64/include/uapi -I./arch/arm64/include/generated/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h -include ./include/linux/compiler_types.h -D__KERNEL__ -mlittle-endian -DKASAN_SHADOW_SCALE_SHIFT=3 -fmacro-prefix-map=./= -Wall -Wundef -Werror=strict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -fshort-wchar -fno-PIE -Werror=implicit-function-declaration -Werror=implicit-int -Werror=return-type -Wno-format-security -std=gnu89 -mgeneral-regs-only -DCONFIG_CC_HAS_K_CONSTRAINT=1 -Wno-psabi -mabi=lp64 -fno-asynchronous-unwind-tables -fno-unwind-tables -msign-return-address=all -Wa,-march=armv8.4-a -DARM64_ASM_ARCH='"armv8.4-a"' -DKASAN_SHADOW_SCALE_SHIFT=3 -fno-delete-null-pointer-checks -Wno-frame-address -Wno-format-truncation -Wno-format-overflow -O2 --param=allow-store-data-races=0 -Wframe-larger-than=2048 -fstack-protector-strong -Wimplicit-fallthrough -Wno-unused-but-set-variable -Wno-unused-const-variable -fno-omit-frame-pointer -fno-optimize-sibling-calls -Wdeclaration-after-statement -Wvla -Wno-pointer-sign -Wno-stringop-truncation -Wno-array-bounds -Wno-stringop-overflow -Wno-restrict -Wno-maybe-uninitialized -fno-strict-overflow -fno-stack-check -fconserve-stack -Werror=date-time -Werror=incompatible-pointer-types -Werror=designated-init -Wno-packed-not-aligned -O1 -Wno-date-time -Idrivers/net/wireless/rtl8723du/include -Idrivers/net/wireless/rtl8723du/platform -Idrivers/net/wireless/rtl8723du/hal -Idrivers/net/wireless/rtl8723du/hal/phydm -DCONFIG_EFUSE_CONFIG_FILE -DEFUSE_MAP_PATH=\"/system/etc/wifi/wifi_efuse_8723du.map\" -DWIFIMAC_PATH=\"/data/wifimac.txt\" -DCONFIG_LOAD_PHY_PARA_FROM_FILE -DREALTEK_CONFIG_PATH=\"/lib/firmware/\" -DCONFIG_RTW_NAPI -DCONFIG_RTW_WIFI_HAL -DCONFIG_RTW_DEBUG -DRTW_LOG_LEVEL=2 -DDM_ODM_SUPPORT_TYPE=0x04  -DMODULE  -DKBUILD_BASENAME='"platform_ops"' -DKBUILD_MODNAME='"8723du"' -c -o drivers/net/wireless/rtl8723du/platform/platform_ops.o drivers/net/wireless/rtl8723du/platform/platform_ops.c

source_drivers/net/wireless/rtl8723du/platform/platform_ops.o := drivers/net/wireless/rtl8723du/platform/platform_ops.c

deps_drivers/net/wireless/rtl8723du/platform/platform_ops.o := \
    $(wildcard include/config/platform/ops.h) \
  include/linux/kconfig.h \
    $(wildcard include/config/cc/version/text.h) \
    $(wildcard include/config/cpu/big/endian.h) \
    $(wildcard include/config/booger.h) \
    $(wildcard include/config/foo.h) \
  include/linux/compiler_types.h \
    $(wildcard include/config/have/arch/compiler/h.h) \
    $(wildcard include/config/enable/must/check.h) \
    $(wildcard include/config/cc/has/asm/inline.h) \
  include/linux/compiler_attributes.h \
  include/linux/compiler-gcc.h \
    $(wildcard include/config/arm64.h) \
    $(wildcard include/config/retpoline.h) \
    $(wildcard include/config/arch/use/builtin/bswap.h) \
    $(wildcard include/config/kcov.h) \
  arch/arm64/include/asm/compiler.h \
  drivers/net/wireless/rtl8723du/platform/platform_ops.h \

drivers/net/wireless/rtl8723du/platform/platform_ops.o: $(deps_drivers/net/wireless/rtl8723du/platform/platform_ops.o)

$(deps_drivers/net/wireless/rtl8723du/platform/platform_ops.o):
