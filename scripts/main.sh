#!/bin/bash

log "Using these configuration parameters" "info"
log "INSTALL_MOD_STRIP: ${INSTALL_MOD_STRIP}" "cfg"
log "KERNELDIR: ${KERNELDIR}" "cfg"
log "PATCHDIR: ${PATCHDIR}" "cfg"
log "PLATFORMDIR: ${PLATFORMDIR}" "cfg"

log "KERNELREPO: ${KERNELREPO}" "cfg"
log "KERNELBRANCH: ${KERNELBRANCH}" "cfg"
log "LOCALVERSION: ${LOCALVERSION}" "cfg"

source "${SRC}"/scripts/functions.sh

get_kernel_repo
get_platform_repo

cd $KERNELDIR
clean_previous_builds

get_latest_kernel

add_additional_sources

add_user_patches

log "Now ready for additional sources and patches" "Info"
read -p "Press [Enter] key to resume ..."

git diff > $PATCHDIR/${KERNELBRANCH}/0001-custom-volumio.patch

kernel_config

compile_kernel

move_to_storage

exit



