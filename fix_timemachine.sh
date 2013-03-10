#!/bin/bash

# Exit on error
set -e

if [[ $(whoami) == 'root' ]]; then
  # Set these to your TM network share details, making sure AFPSHARE is wrapped
  # in quotes if it contains spaces in the name.
  USER=user
  HOSTNAME=host.local
  AFPSHARE="Time Machine"

  # You probably don't need to edit this, which is the name of the sparsebundle
  # that you're backing up to. It will default to the name of the current
  # machine, which is usually correct.
  TM_NAME=$(hostname -s)

  # Don't change these...
  MOUNT=/Volumes/TimeMachine
  SPARSEBUNDLE="$MOUNT/${TM_NAME}.sparsebundle"
  PLIST="${SPARSEBUNDLE}/com.apple.TimeMachine.MachineID.plist"

  read -s -p 'Enter Time Machine Share Password:' PASSWORD

  echo "Disabling TimeMachine"
  tmutil disable

  echo "Unmounting ${AFPSHARE}"
  while mount | grep "${AFPSHARE}" > /dev/null; do  mount | grep "${AFPSHARE}" | awk '{print $3}' | xargs -n1 -I{} umount -f {}; done  

  echo "Mounting volume"
  mkdir $MOUNT
  mount_afp "afp://${USER}:${PASSWORD}@${HOSTNAME}/${AFPSHARE}" "${MOUNT}"

  echo "Changing file and folder flags"
  chflags -R nouchg "${SPARSEBUNDLE}"

  echo "Attaching sparse bundle"
  DISK=$(hdiutil attach -nomount -readwrite -noverify -noautofsck "${SPARSEBUNDLE}" | grep 'Apple_HFS' | awk '{ print $1 }')  

  echo "Repairing volume"
  diskutil repairVolume ${DISK}
  /sbin/fsck_hfs -fry ${DISK}

  echo "Fixing Properties"
  cp "${PLIST}" "${PLIST}.backup"
  sed -e '/RecoveryBackupDeclinedDate/{N;d;}'   \
      -e '/VerificationState/{n;s/2/0/;}'       \
      "${PLIST}.backup" \
       > "${PLIST}"

  echo "Unmounting volumes"
  hdiutil detach ${DISK}
  umount "${MOUNT}"

  echo "Enabling TimeMachine"
  tmutil enable

  echo "Starting backup"
  tmutil startbackup
  
else
  echo Please run this script as root.
fi
