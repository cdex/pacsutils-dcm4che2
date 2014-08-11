#!/bin/sh

. $( dirname "${0}" )/base.environments

if [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] ; then
    echo "Usage: $0 destination_directory zip_file study_instance_uid"
    exit 2
fi
destdir="${WORK_DIR}/${1}"
if [ -d "${destdir}" ]; then
    echo "Already exists:$destdir" >&2
    exit 1
fi
if [ "x${ARCH_DIR}" = 'x' ]
then
    echo "Set ARCH_DIR in ./base.environments" >&2
    exit 1
fi
zipfile="${ARCH_DIR}/${2}"
if [ -e "${zipfile}" ] ; then
    echo "Already exists: ${zipfile}" >&2
    exit 10
fi
status=0
studyinstanceuid="$3"
mkdir "${destdir}"
if [ $? != 0 ]; then
   echo "[Fatal Error] Can not create : $destdir" >&2
   exit 2
fi
# echo "Listening at ${RETV_AET}" 
# ${CMD_BASE}/dcmrcv ${RETV_AET} -dest "$destdir"  1> /dev/null &
# rcvpid="$!"
# sleep 1
# ps -p "$rcvpid" > /dev/null
# if [ "$?" != 0  ]; then
#     echo "[Fatal Error] Could not start ${CMD_BASE}/dcmrcv ${RETV_AET} -dest ${destdir}" >&2
#     exit 100
# fi
rcvaet=`echo ${RETV_AET} | sed 's:@.*$::'`
echo "Sending study $studyinstanceuid from ${SEND_AET} to $rcvaet..."
${CMD_BASE}/dcmqr "${SEND_AET}" -L "${RETV_AET}" -cmove "${rcvaet}" -q0020000D="${studyinstanceuid}" -cstore CT -cstore SC -cstoredest "${destdir}" >&1 > "${LOGS_DIR}/dcmqr.${studyinstanceuid}.log"
num_of_object=`grep Retrieved "${LOGS_DIR}/dcmqr.${studyinstanceuid}.log"`
fcount=`echo "$num_of_object" | cut -d" " -f7`
wfile=`echo "$num_of_object" | cut -d" " -f10 | sed -e s/,//`
efile=`echo "$num_of_object" | cut -d" " -f12 | sed -e s/\)//`
if [ "${wfile}" != '0'  ] || [ "${efile}" != '0' ] ; then
    ls -1 "${LOGS_DIR}/dcmqr.${studyinstanceuid}.log" >&2
    status=100
fi
# kill -s 15 "$rcvpid"
# while [ "" = "" ]; do
#     ps -p "$rcvpid" > /dev/null
#     if [ "$?" != 0  ]; then
# 	break;
#     fi
#     echo -n "T"
#     sleep 1
# done
# echo ",Terminated listening."
if [ ${status} != 0 ]; then
    exit ${status}
fi

cd "${destdir}"
zip -9qr "${zipfile}" . >& /dev/null
cd ${LOCAL_CMD}
if [ "$?" = "0" ]; then
     zip -Tq "${zipfile}"   >& /dev/null
     if [ "$?" = "0" ]; then
         rm -rf "${destdir}"
     else 
         rm -rf "${destdir}"
         rm -f "${zipfile}"
         echo "[Fatal Error] while zip -T ${zipfile}" >&2
         exit 3
     fi
else
         rm -rf "${destdir}"
         echo "[Fatal Error] while zip ${zipfile}" >&2
         exit 3
fi
echo "Retrievefiles:$fcount"
exit $status
