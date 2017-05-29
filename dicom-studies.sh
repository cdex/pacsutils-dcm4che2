#!/bin/bash

################################################################################
## Lists studies with each study's instance UID, number of instances, patient's
## name and ID, and study date-time to a file in WORK_DIR. The latter three are
## joined by '.' and the first, second and third--fifth are delimited by a tab
################################################################################

. $( dirname "${0}" )/base.environments

day=`date +%Y-%m-%d`
study=study-list.$day
if [ -f ${WORK_DIR}/$study ] ; then
  echo ${WORK_DIR}/$study
  exit 1 
fi
#09:52:40,995 INFO   - Query Response #2465:
#(0008,0005) CS #10 [ISO_IR 100] Specific Character Set
#(0008,0052) CS #8 [PATIENT] Query/Retrieve Level
#(0008,0054) AE #0 [] Retrieve AE Title
#(0008,0056) CS #0 [] Instance Availability
#(0010,0010) PN #18 [000000000000011200] Patient's Name
#(0010,0020) LO #12 [902C9001C2H3] Patient ID
#(0010,0030) DA #0 [] Patient's Birth Date
#(0010,0040) CS #0 [] Patient's Sex
#(0020,1200) IS #0 [] Number of Patient Related Studies
#(0020,1202) IS #0 [] Number of Patient Related Series
#(0020,1204) IS #0 [] Number of Patient Related Instances
#(0088,0130) SH #0 [] Storage Media File-set ID
#(0088,0140) UI #0 [] Storage Media File-set UID

${CMD_BASE}/dcmqr ${SEND_AET} -L${RETV_AET} -r PatientName -r PatientID \
    | sed -n '/^[0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]* INFO   - Query Response #\([1-9][0-9]*\):/h; /^(00[012][08],[01][02][0123][80D])/{s:^:\t:;H}; /^$/{x;/^[0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]* INFO   - Query Response #[1-9][0-9]*:/{s:\n::g; p}}' \
    | sed 's/^[0-2][0-9]:[0-5][0-9]:[0-5][0-9],[0-9]* INFO   - Query Response #\([1-9][0-9]*\):\t(0008,0020) DA #[1-9][0-9]* \[\(.*\)\] Study Date\t(0008,0030) TM #[1-9][0-9]* \[\(.*\)\] Study Time\t(0010,0010) PN #[1-9][0-9]* \[\(.*\)\] Patient.s Name\t(0010,0020) LO #[1-9][0-9]* \[\(.*\)\] Patient ID\t(0020,000D) UI #[1-9][0-9]* \[\(.*\)\] Study Instance UID\t(0020,0010) SH #[1-9][0-9]* \[\(.*\)\] Study ID\t(0020,1208) IS #[1-9][0-9]* \[\(.*\)\] Number of Study Related Instances$/\6\t\8\t\4.\5.\2T\3/;' \
    > ${WORK_DIR}/$study
if [ $? != 0 ]; then
    echo "[Fatal Error] Can not create : study-list" >&2
    exit 2 
fi

echo ${WORK_DIR}/$study

exit 0
