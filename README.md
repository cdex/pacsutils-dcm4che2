PACS Utilities
--------------

### Requirements

* [dcm4che](http://dcm4che.org), Version 2
* Java Runtime Environment, required by dcm4che

### Environment variables

* `JAVA_HOME`, optional, e.g. `/usr/java/jre1.7.0_55`

### Configuration

* Edit `./base.environments`.
* Make directories LOGS_DIR, WORK_DIR and ARCH_DIR specified in
  `./base.environments`

### Typical procedures

#### Retrieves DICOMs from the remote storage and saves to ZIP files

* Execute `./dicom-studies.sh`
* Delete some lines in study-list.YYYY-MM-DD in WORK_DIR in order to exclude
* Execute `./archive-dicom.sh`
* Check retrieve.log in LOGS_DIR
* Check dcmqr.*.log in LOGS_DIR if needed
* Save ZIP files in ARCH_DIR
