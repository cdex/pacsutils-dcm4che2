#!/bin/sh

################################################################################
## Compares a ZIP filename and a DICOM header in the ZIP file
################################################################################

. ./base.environments

if [ "$1" = "" ] ; then
    echo "Usage: $0 dicom zip file name" >&2
    exit 1 
fi
wkdir=${WORK_DIR}/header.$$
mkdir $wkdir
unzip $1 -d $wkdir >& /dev/null
if [ "$?" != "0" ]; then
    echo "[Fatal Error] while unzip  $1" >&2
    rm -rf $wkdir
    exit 3
fi
cd $wkdir
for f in * 
  do
  sopinstanceuidinheader=`${CMD_BASE}/dcm2txt --width 512 "$f" | grep '^[0-9]*:(0008,0018)' | sed 's:^.*\[\([0-9\.]*\).*$:\1:'`
  if [ "$f" != "$sopinstanceuidinheader" ]; then
      echo "DICOM Header Error: SOP:$f     ZIP FileName:$1"
      exit 2;
  fi
done
cd ${LOCAL_CMD}
rm -rf $wkdir
exit 0
