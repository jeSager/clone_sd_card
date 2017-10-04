#! /bin/bash

SDCARD=/dev/sdc
IMG=./sdcard.img

################################################################################
#
# CLONE SD CARD SCRIPT
# ====================
#
#   Functions
#   ---------
#     f_MAIN()              --Lists blocks and displays functional options
#     f_DISK_TO_SD_LOOP     --Overwrites the $SDCARD
#     f_SD_TO_DISK()        --Overwrites the $IMG file
#     f_CHECK_CARD()        --Exits if $SDCARD DNE
#     f_CHECK_IMG()         --Options if $IMG DNE
#     f_START_MSG()         --Text
#     f_ALERT()             --Notification
#
#  Author:     jeSager
#  Modified:   Wednesday, 4 October 2017
################################################################################



f_MAIN() {

  # ===================================
  # List block devices, check the SD card, and display the start message
  echo; echo; lsblk; echo; echo
  f_CHECK_CARD
  f_START_MSG

  # ===================================
  # Choose from functional options
  echo
  echo "Select from the Following Options"
  echo "================================="
  OPT=("Create New Image File On Disk From SD Card")
  OPT+=("Clone Image File on Disk to the SD Card")
  OPT+=("Quit")
  PS3='Enter a Number:  '
  select n in "${OPT[@]}"; do
    case $n in
      ${OPT[0]})  f_SD_TO_DISK; break;;
      ${OPT[1]})  f_DISK_TO_SD_LOOP; break;;
      ${OPT[2]})  break;;
      *)          echo ***INVALID OPTION***;;
    esac
  done
}



f_DISK_TO_SD_LOOP() {
  f_CHECK_IMG
  if [[ VALID_IMG ]]; then
    clear
    echo "  ****************************************************************"
    echo "  * DISK TO SD START MESSAGE"
    echo "  * ========================"
    echo "  * This option will overwrite the physical SD card with the "
    echo "  * image file located on disk -- as many times as needed."
    echo "  * "
    echo "  * SD CARD LOCATION:     $SDCARD."
    echo "  * DISK IMAGE LOCATION:  $IMG"
    echo "  *"
    echo "  ****************************************************************"
    while [[ $in == "" ]]; do
      echo
      echo
      echo " ***************************************************************"
      echo " * CLONE SCRIPT OPTIONS"
      echo " * ===================="
      echo " * 1)  Insert a new SDCARD and press <ENTER> to continue."
      echo " * 2)  Enter \"q\" or any text to quit this script."
      echo " ***************************************************************"
      read in
      if [[ $in == "" ]]; then
        dd if=$IMG of=$SDCARD bs=64K conv=noerror,sync status=progress
        f_ALERT
      fi
    done
  fi
}



f_SD_TO_DISK() {
  clear
  echo "  ****************************************************************"
  echo "  * SD TO DISK START MESSAGE"
  echo "  * ========================"
  echo "  *   This option will overwrite the file $IMG with the contents "
  echo "  *   of the SD card."
  echo "  *   "
  echo "  *   SD CARD LOCATION:     $SDCARD."
  echo "  *   DISK IMAGE LOCATION:  $IMG"
  echo "  *"
  echo "  *   <ENTER> to continue."
  echo "  *   Enter \"q\" or any text to quit."
  echo "  *"
  echo "  ****************************************************************"
  read in
  if [[ $in == "" ]]; then
    dd if=$SDCARD of=$IMG bs=64K conv=noerror,sync status=progress
    f_ALERT
  fi
}



f_CHECK_CARD(){
  if [[ "$SDCARD" != "$(ls $SDCARD)" ]]; then
    f_ALERT
    echo " ****************************************************************"
    echo " * ERROR:  SD CARD NOT FOUND!"
    echo " * ========================="
    echo " *   - THERE IS NO SD CARD IN THE SLOT, OR YOU MUST ENTER A VALID"
    echo " *     SD CARD LOCATION FOR THE SCRIPT'S \$SDCARD CONSTANT."
    echo " *"
    echo " *   - IF THERE IS A CARD IN THE SLOT, THE FOLLOWING LINE IN THE "
    echo " *     SCRIPT IS INVALID:"
    echo " *        \$SDCARD=$SDCARD"
    echo " *"
    echo " *   - USE THE LIST OF BLOCK DEVICES ABOVE TO FIX THE PROBLEM."
    echo " *"
    echo " *   - THE SCRIPT WILL NOW EXIT."
    echo " ****************************************************************"
    exit
  fi
}



f_CHECK_IMG(){
  if [[ ! -e $IMG ]]; then
    echo " ****************************************************************"
    echo " *  ERROR:  IMAGE FILE DOES NOT EXIST"
    echo " *"
    echo " ****************************************************************"
    echo
    echo "Select from the Following Options"
    echo "================================="
    OPT=("Create New Image File On Disk From SD Card")
    OPT+=("Quit")
    PS3='Enter a Number:  '
    select n in "${OPT[@]}"; do
      case $n in
        ${OPT[0]})   f_SD_TO_DISK; break;;
        ${OPT[1]})   break;;
        *)           echo ***INVALID OPTION***;;
      esac
    done
    VALID_IMG=false
  fi
  VALID_IMG=true
}



f_START_MSG(){
  echo " ****************************************************************"
  echo " * CLONE SCRIPT START MESSAGE"
  echo " * =========================="
  echo " * - YOUR BLOCK DEVICES HAVE BEEN LISTED ABOVE."
  echo " *"
  echo " * - BE SURE YOUR SD CARD IS LISTED AT THE LOCATION BELOW"
  echo " *   CHANGE THE CONSTANT \$SDCARD VARIABLE IF NEEDED."
  echo " *"
  echo " *   LOCATION:  $SDCARD"
  echo " *"
  echo " ****************************************************************"
  echo " <ENTER> to view options"
  read
  clear
}



# ===========================
# Plays the sound, if it can
f_ALERT(){
  if [[ -e ./myalert.ogg && $(which paplay) != "" ]]; then
    paplay ./myalert.ogg&
  fi
}



# ===========================
# Runs the script
f_MAIN



clear
echo "The clone script ended successfully"
echo
