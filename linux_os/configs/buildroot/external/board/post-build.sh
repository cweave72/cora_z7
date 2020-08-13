#!/bin/sh
# args from BR2_ROOTFS_POST_SCRIPT_ARGS
# $2    board name
. ${BR2_CONFIG}
set -e

INSTALL=install

BOARD_DIR="$(dirname $0)"
BOARD_NAME="$(basename ${BOARD_DIR})"

${INSTALL} -D -m 0755 ${BOARD_DIR}/S40network ${TARGET_DIR}/etc/init.d/
${INSTALL} -D -m 0644 ${BOARD_DIR}/motd ${TARGET_DIR}/etc/
${INSTALL} -D -m 0644 ${BOARD_DIR}/aliases.sh ${TARGET_DIR}/etc/profile.d/
${INSTALL} -D -m 0644 ${BOARD_DIR}/device_config ${TARGET_DIR}/etc/
