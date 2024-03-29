#!/bin/bash

get_kernel_repo() {
if [ ! -d  $KERNELDIR ]; then
  log "Kernel directory does not exist, cloning from kernel.org"
  git clone ${KERNELREPO} ${KERNELDIR} -b linux-${KERNELBRANCH}
fi
}

get_platform_repo() {
  log "Getting the latest x86 platform files"
  if [ -d ${PLATFORMDIR} ]; then
    log "Platform folder exists, update" "info"
    pushd ${PLATFORMDIR} 1> /dev/null 2>&1
    git pull
    popd 1> /dev/null 2>&1
  else
    log "Platform folder does not exist, cloning the repo" "info"
    git clone ${PLATFORMREPO} --depth 1
  fi

}

clean_previous_builds() {

  KVER=$(cat Makefile| grep "^VERSION = " | awk -F "= " '{print $2}')
  KPATCH=$(cat Makefile| grep -e "^PATCHLEVEL = " | awk -F "= " '{print $2}')
  KSUB=$(cat Makefile| grep -e "^SUBLEVEL = " | awk -F "= " '{print $2}')
  KVERPREV=${KVER}.$KPATCH.$KSUB$LOCALVERSION

  log "Previous versions"
  log "Kernel version ${KVER}" "info"
  log "Kernel patch ${KPATCH}" "info"
  log "Kernel sub version ${KSUB}" "info"
  log "Previous build version ${KVERPREV}" "info"

  log "Removing previous build versions from the build folder/"
  [[ -d ../$KERNELDIR.orig ]] && rm -r ../$KERNELDIR.orig
  [[ -d ../$KERNELDIR/debian ]] && rm -r ../$KERNELDIR/debian

  log "Removing old build versions from the platform folder"
  set -- $PLATFORMDIR/amd64*${KVERPREV}*_defconfig
  if [ -f "$1" ]; then
    rm $PLATFORMDIR/amd64*${KVERPREV}*_defconfig
  fi
  set -- $PLATFORMDIR/linux-*${KVERPREV}*.deb
  if [ -f "$1" ]; then
    rm $PLATFORMDIR/linux-*${KVERPREV}*.deb
  fi

}

get_latest_kernel() {

  log "Getting the latest kernel version"
  if [[ ! $KERNELBRANCH =~ "-rc" ]]; then
    log "Cleaning the kernel repo"
    git clean -qdfx
    git checkout -qf HEAD
    git pull
  else
    log "$KERNELBRANCH is a release candidate, up-to-date"
  fi  

  KVER=$(cat Makefile| grep "^VERSION = " | awk -F "= " '{print $2}')
  KPATCH=$(cat Makefile| grep -e "^PATCHLEVEL = " | awk -F "= " '{print $2}')
  KSUB=$(cat Makefile| grep -e "^SUBLEVEL = " | awk -F "= " '{print $2}')
  KERNELVER=${KVER}.$KPATCH.$KSUB$LOCALVERSION

  log "Current versions"
  log "Kernel version ${KVER}" "cfg"
  log "Kernel patch ${KPATCH}" "cfg"
  log "Kernel sub version ${KSUB}" "cfg"

  echo 1 > .version
  log "Package version $KERNELVER-$(<.version)" "info"
  touch .scmversion
}

add_additional_sources() {
  log "Checking custom additions"
  if [ ! -d ${SRC}/sources/${KERNELBRANCH} ] ; then
    log "No custom kernel sources found" "wrn"
  else
    log "Adding additional kernel sources" "info"
    cp -dR ${SRC}/sources/${KERNELBRANCH}/* .
  fi

  log "Adding the default amd64-volumio-min kernel configuration" "info"
  if [ -f ${PLATFORMDIR}/${KERNELCONFIG} ]; then
    cp ${PLATFORMDIR}/${KERNELCONFIG} ${KERNELDIR}/arch/x86/configs/${KERNELCONFIG}
  else
    set -- $PLATFORMDIR/amd64-volumio-min*
    if [ -f "$1" ]; then
      log "Custom kernel configuration file does not exist, copy from last compiled kernel configuration"
      cp ${PLATFORMDIR}/amd64-volumio-min*_defconfig ${KERNELDIR}/arch/x86/configs/${KERNELCONFIG}
    else
      log "Default kernel configuration not found, aborting" "err"
      exit 255
    fi
  fi
}

add_user_patches() {

  if [ ! -d ${SRC}/patches/${KERNELBRANCH} ] ; then
    log "No custom patches found" "wrn"
  else
    log "Applying accumulative kernel patches"
    for f in ${PATCHDIR}/${KERNELBRANCH}/*
      do
      log "Appying $f" "info"
      git apply $f
    done
  fi
}

kernel_config() {

  log "Preparing volumio kernel config file"
  make clean
  log "Using configuration ${KERNELDIR}/arch/x86/configs/${KERNELCONFIG}" "info"
  make ${KERNELCONFIG}
  make menuconfig
  log "Saving .config to defconfig"
  make savedefconfig
  echo "Copying defconfig to volumio kernel config"
  cp defconfig ${KERNELDIR}/arch/x86/configs/${KERNELCONFIG}
}

compile_kernel() {

  log "Copying volumio kernel config to platform folder (history)"
  cp defconfig $PLATFORMDIR/amd64-volumio-min-${KERNELVER}-`date +%Y.%m.%d-%H.%M`_defconfig
  cp defconfig $PLATFORMDIR/amd64-volumio-min-${KERNELBRANCH}_defconfig

  log "Compiling kernel ${KERNELVER}"
  start=$(date +%s.%N)
  make -j$(nproc) deb-pkg
}

move_to_storage() {

  log "Keep local copies"
  [ -d ../local-debs ] || mkdir ../local-debs
  cp ../linux-headers-${KERNELVER}_*amd64*.deb ../local-debs/linux-headers-${KERNELVER}_local_amd64.deb
  cp ../linux-image-${KERNELVER}_*amd64*.deb ../local-debs/linux-image-${KERNELVER}_local_amd64.deb

  HEADERS=$(ls ../linux-headers-${KERNELVER}_*amd64*.deb)
  IMAGE=$(ls ../linux-image-${KERNELVER}_*amd64*.deb)

  log "Check if .deb packages were compressed with ZSTD, re-pack it for usage with Debian 10" "info"
  # if one is zstd compressed, all are (Ubuntu >= 21.04, Debian >= 12)
  ar -x $HEADERS
  if [ -f "control.tar.zst" ]; then

    log "Re-packing $HEADERS"
    # Uncompress zstd files an re-compress them using xz
    zstd -d < control.tar.zst | xz -v > control.tar.xz
    zstd -d < data.tar.zst | xz -v > data.tar.xz
    rm $HEADERS
    ar r $HEADERS debian-binary control.tar.xz data.tar.xz
    rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst

    log "Re-packing $IMAGE"
    ar -x $IMAGE
    zstd -d < control.tar.zst | xz -v > control.tar.xz
    zstd -d < data.tar.zst | xz -v > data.tar.xz
    rm $IMAGE
    ar r $IMAGE debian-binary control.tar.xz data.tar.xz
    rm debian-binary control.tar.xz data.tar.xz control.tar.zst data.tar.zst
  fi

  log "Backup .deb files"
  rsync --remove-source-files -rq ../*.deb "$PLATFORMDIR"
  find ../ -maxdepth 1 -type f -name 'linux-*' -delete

  log "Build kernel completed" "okay"
  dur=$(echo "$(date +%s.%N) - $start" | bc)
  log "$(printf 'Execution time: %.6f seconds\n' $dur)"
  
  log "Manually remove the .deb copies from the local-debs folder when not needed" "info"
  cd ..
}
