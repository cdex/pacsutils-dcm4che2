#!/bin/sh

################################################################################
## Reads study list made by dicom-studies.sh and calls dicom-retrieve.sh for
## each study
################################################################################

. $( dirname "${0}" )/base.environments

studylist=`sh ${LOCAL_CMD}/dicom-studies.sh`
case "$?" in
  1)
  echo "Already exists:$studylist"
  ;;
  2)
  echo "Fatal Error : Stoped Process :${LOCAL_CMD}/dicom-studies.sh" >&2
  exit 1
  ;;
esac

l=`cat $studylist | wc -l`
for i in `seq 1 $l`
  do
  studyline=`head -"$i" "$studylist" | tail -1`
  studyiuid=`echo "$studyline" | cut -f1`
  filecount=`echo "$studyline" | cut -f2`
  archname=`echo "$studyline" | cut -f3`
  if [ "$studyiuid" = "" ] || [ "$filecount" = "" ] || [ "$archname" = "" ]; then
      echo "[Error] Wrong study information" >&2
      continue
  fi
  day=`date +%Y-%m-%dT%H:%M`
  num_of_file=`sh ${LOCAL_CMD}/dicom-retrieve.sh "${archname}" "${archname}.zip" $studyiuid`
  retv="$?"
  a=`echo "$num_of_file" | grep Retrievefiles:`
  b=`echo "$a" | sed -e s/Retrievefiles\://`
  case "$retv" in
    0)
    status="COMLETE"
#     sh ${LOCAL_CMD}/dicom-header-chk.sh ${WORK_DIR}/$archname.zip
#     if [ $?  = 0 ] ; then
#        header="OK"
#     else
#        header="NG"
#     fi
    header="NONE"
    ;;
    10)
    echo "Already exists: $studyline"
    continue
    ;;
    2)
    echo "Fatal Error : Stoped Process :${LOCAL_CMD}/dicom-retrieve.sh" >&2
    status="FATALERROR"
    exit 1
    ;;
    3)
    echo "Error : while zip : $studyline" >&2
    status="ZIPERROR"
    ;;
    100)
    echo "Retrieve unkown Error: Make sure log files or try again : $studyline" >&2
    status="UNKNOWN"
    ;;
  esac
  echo "$day	$b	$status	$header	*	$studyline" >> ${LOGS_DIR}/retrieve.log
  if [ "x${status}" = "xFATALERROR" ] ; then
     exit 1
  fi
done
echo `date +%Y-%m-%dT%H%M%S%z`' [Finished]'
