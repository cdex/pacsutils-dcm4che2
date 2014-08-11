#!/bin/sh
if [ $# != 1 ]; then
   echo "Usage: send_to_dicom.sh dicom-archive-zipfile"
   exit 1
fi

echo "$0 has not been not tested yet after changing to check the standard error of dcmsnd." >&2 ###

. $( dirname "${0}" )/base.environments

a=`/usr/bin/zipinfo -h $1`
infile=`echo "$a" | cut -d" " -f9`
if [ "$?" != "0" ]; then
      echo "zipinfo unsuccessful:$1" >&2
      exit 3
fi
workdir="${WORK_DIR}/workdir.$$"
if [ $? != 0 ] ; then
   echo "Can not create work directory: $workdir"
   exit 1
fi
/usr/bin/unzip $1 -d $workdir > /dev/null 2>&1
if [ "$?" != "0" ]; then
      echo "zipinfo unsuccessful:$1" >&2
      exit 3
fi
day=`date +%Y-%m-%dT%H%M`
echo -n "Send Start $day"
echo -n "	$1"
status="COMPLETE"
dcmsnderr="${WORK_DIR}/dcmsnd.$$.err"
${CMD_BASE}/dcmsnd -L ${CALLING_AET} ${CALLED_AET} $workdir > /dev/null 2> "${dcmsnderr}"
RT="$?"
echo "	Finish"
rm -rf $workdir
if [ "$RT" != "0" ] || [ -s "${dcmsnderr}" ]; then
   status="FAILED"
   echo "	sent unsuccessful" >&2
   echo "$day	$infile	$1	$status"  >> ${LOGS_DIR}/send-dicom.log
   if [ -s "${dcmsnderr}" ]; then
       cat "${dcmsnderr}" >&2
   fi
   rm "${dcmsnderr}"
   exit 100
fi
echo "$day	$infile	$1	$status"  >> ${LOGS_DIR}/send-dicom.log
rm "${dcmsnderr}"
exit 0
