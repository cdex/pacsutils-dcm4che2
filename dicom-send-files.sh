#!/bin/sh
if [ $# != 1 ]; then
   echo "Usage: send_to_dicom.sh dicom-files"
   exit 1
fi

. ./base.environments

workdir="${WORK_DIR}/workdir.$$"
if [ $? != 0 ] ; then
   echo "Can not create work directory: $workdir"
   exit 1
fi
cp $1 -d $workdir
day=`date +%Y-%m-%dT%H%M`
echo -n "Send Start $day"
echo -n "	$1"
status="COMPLETE"
${CMD_BASE}/dcmsnd -L ${CALLING_AET} ${CALLED_AET} $workdir > /dev/null
RT="$?"
echo "	Finish"
rm -rf $workdir
if [ "$RT" != "0" ]; then
   status="FAILED"
   echo "	sent unsuccessful" >&2
   echo "$day	$infile	$1	$status"  >> ${LOGS_DIR}/send-dicom.log
   exit 100
fi
echo "$day	$infile	$1	$status"  >> ${LOGS_DIR}/send-dicom.log
exit 0
