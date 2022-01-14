#!/bin/sh
#
# $Header: dbaas/docker/build/dbsetup/setup/configDBora.sh rduraisa_docker_122_image/6 2017/04/02 06:29:55 rduraisa Exp $
#
# configDBora.sh
#
# Copyright (c) 2016, 2017, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#      configDBora.sh - configure database as oracle user
#
#    DESCRIPTION
#      rename the DB to customized name
#
#    NOTES
#      run as oracle
#
#    MODIFIED   (MM/DD/YY)
#    rduraisa    03/02/17 - Modify scripts to build for 12102 and 12201
#    xihzhang    10/25/16 - Remove EE bundles
#    xihzhang    08/08/16 - Remove privilege mode
#    xihzhang    05/23/16 - Creation
#

/etc/init.d/oracle-xe start | grep -qc "Oracle Database 11g Express Edition is not configured"
export ORACLE_PWD=${ORACLE_PWD:-"`openssl rand -hex 8`"}
echo "ORACLE PASSWORD FOR SYS AND SYSTEM: $ORACLE_PWD";

sed -i -e "s|###ORACLE_PWD###|$ORACLE_PWD|g" $ORACLE_BASE/$CONFIG_RSP && \
/etc/init.d/oracle-xe configure responseFile=$ORACLE_BASE/$CONFIG_RSP
#u01/app/oracle/product/11.2.0/xe/config/scripts/oracle-xe  configure responseFile=$ORACLE_BASE/$CONFIG_RSP


LSNR_ORA=$ORACLE_HOME/network/admin/listener.ora

TNS_ADMIN=$ORACLE_HOME/network/admin/
echo "$TNS_ADMIN"
echo $TNS_ADMIN

SQLNET_ORA=$TNS_ADMIN/sqlnet.ora
echo "NAME.DIRECTORY_PATH= {TNSNAMES, EZCONNECT, HOSTNAME}" >> $SQLNET_ORA
echo "SQLNET.EXPIRE_TIME = 10" >> $SQLNET_ORA
echo "SSL_VERSION = 1.0" >> $SQLNET_ORA
# listener.ora
LSNR_ORA=$TNS_ADMIN/listener.ora
echo "LISTENER = \
  (DESCRIPTION_LIST = \
    (DESCRIPTION = \
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) \
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521)) \
    ) \
  ) \
\
" >> $LSNR_ORA
echo "DIAG_ADR_ENABLED = off"  >> $LSNR_ORA
echo "SSL_VERSION = 1.0"  >> $LSNR_ORA
# tnsnames.ora
TNS_ORA=$TNS_ADMIN/tnsnames.ora
echo "$DB_SID = \
  (DESCRIPTION = \
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) \
    (CONNECT_DATA = \
      (SERVER = DEDICATED) \
      (SERVICE_NAME = $DB_SID.$DB_DOMAIN) \
    ) \
  ) \
" >> $TNS_ORA
echo "$DB_PDB = \
  (DESCRIPTION = \
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) \
    (CONNECT_DATA = \
      (SERVER = DEDICATED) \
      (SERVICE_NAME = $DB_PDB.$DB_DOMAIN) \
    ) \
  ) \
" >> $TNS_ORA

su -p oracle -c "sqlplus / as sysdba <<EOF
      EXEC DBMS_XDB.SETLISTENERLOCALACCESS(FALSE);
      
      ALTER DATABASE ADD LOGFILE GROUP 4 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo04.log') SIZE 50m;
      ALTER DATABASE ADD LOGFILE GROUP 5 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo05.log') SIZE 50m;
      ALTER DATABASE ADD LOGFILE GROUP 6 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo06.log') SIZE 50m;
      ALTER SYSTEM SWITCH LOGFILE;
      ALTER SYSTEM SWITCH LOGFILE;
      ALTER SYSTEM CHECKPOINT;
      ALTER DATABASE DROP LOGFILE GROUP 1;
      ALTER DATABASE DROP LOGFILE GROUP 2;
      
      ALTER SYSTEM SET db_recovery_file_dest='';
      exit;
EOF"




echo "start listener"
cmd_output=$(lsnrctl start)
cmd_output=$(lsnrctl services)
  # Listener 
#    echo "# listener.ora Network Configuration File:
         
#          SID_LIST_LISTENER = 
#            (SID_LIST =
#              (SID_DESC =
#                (SID_NAME = PLSExtProc)
#                (ORACLE_HOME = $ORACLE_HOME)
#                (PROGRAM = extproc)
#              )
#            )
         
#          LISTENER =
#            (DESCRIPTION_LIST =
#              (DESCRIPTION =
#                (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC_FOR_$ORACLE_SID))
#                (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
#              )
#            )
         
#          DEFAULT_SERVICE_LISTENER = ($ORACLE_SID)" > $ORACLE_HOME/network/admin/listener.ora

# # TNS Names.ora
#    echo "# tnsnames.ora Network Configuration File:

# $ORACLE_SID =
#   (DESCRIPTION =
#     (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
#     (CONNECT_DATA =
#       (SERVER = DEDICATED)
#       (SERVICE_NAME = $ORACLE_SID)
#     )
#   )

# EXTPROC_CONNECTION_DATA =
#   (DESCRIPTION =
#      (ADDRESS_LIST =
#        (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC_FOR_$ORACLE_SID))
#      )
#      (CONNECT_DATA =
#        (SID = PLSExtProc)
#        (PRESENTATION = RO)
#      )
#   )
# " > $ORACLE_HOME/network/admin/tnsnames.ora

# basic parameters
SETUP_DIR=/home/oracle/setup

IFS='.' read -r -a dbrelarr <<< 12.2.0

if [[ ${dbrelarr[0]} == 12 && ${dbrelarr[1]} == 1 ]];
then
    PATCH_LOG=${SETUP_DIR}/log/patchDB.log
    # unpatch opc features
    echo "Patching Database ...."
    /bin/bash ${SETUP_DIR}/patchDB.sh 2>&1 >> ${PATCH_LOG}

    $ORACLE_HOME/bin/relink as_installed
fi

#setup directories and soft links
echo "Setup Database directories ..."
mkdir -p /ORCL/u01/app/oracle/diag /u01/app/oracle /u02/app/oracle /u03/app/oracle /u04/app/oracle
mkdir -p $TNS_ADMIN
ln -s /ORCL/$ORACLE_HOME/dbs $ORACLE_HOME/dbs
ln -s /ORCL/u01/app/oracle/diag /u01/app/oracle/diag
ln -s /ORCL/u02/app/oracle/audit /u02/app/oracle/audit
ln -s /ORCL/u02/app/oracle/oradata /u02/app/oracle/oradata
ln -s /ORCL/u03/app/oracle/fast_recovery_area /u03/app/oracle/fast_recovery_area
ln -s /ORCL/u04/app/oracle/redo /u04/app/oracle/redo

if [[ $EXISTING_DB = false ]];
then
  cd /u01/app/oracle/product/12.2.0/dbhome_1/dbs/
  # set domain
  echo "*.db_domain='$DB_DOMAIN'" >> initORCLCDB.ora
  # set sga & pga
  MEMORY=${DB_MEMORY//[!0-9]/}
  SGA_MEM=$(($MEMORY * 640))M
  PGA_MEM=$(($MEMORY * 384))M
  echo "*.sga_target=$SGA_MEM" >> initORCLCDB.ora
  echo "*.pga_aggregate_target=$PGA_MEM" >> initORCLCDB.ora

  # create the diag directory to avoid errors with the below mv command
  mkdir -p /u01/app/oracle/diag/rdbms/orclcdb/ORCLCDB

  if [ "$DB_SID" != "ORCLCDB" ]
  then
  # mount db
      sqlplus / as sysdba 2>&1 <<EOF
      startup mount pfile=/u01/app/oracle/product/12.2.0/dbhome_1/dbs/initORCLCDB.ora;
      exit;
EOF

  # nid change name
      echo "NID change db name"
      echo "Y" | nid target=/ dbname=$DB_SID

  # update init.ora
      rm -f init$DB_SID.ora
      cp initORCLCDB.ora init$DB_SID.ora

  # change sid
      sed -i -- "s#ORCLCDB#$DB_SID#g" init$DB_SID.ora

  # rename all the dirs/files
      mv /u01/app/oracle/diag/rdbms/orclcdb/ORCLCDB /u01/app/oracle/diag/rdbms/orclcdb/$DB_SID
      mv /u01/app/oracle/diag/rdbms/orclcdb /u01/app/oracle/diag/rdbms/${DB_SID,,}
      mv /u02/app/oracle/audit/ORCLCDB /u02/app/oracle/audit/$DB_SID
      mv /u02/app/oracle/oradata/ORCLCDB /u02/app/oracle/oradata/$DB_SID   # cp -R
      mv /u03/app/oracle/fast_recovery_area/ORCLCDB /u03/app/oracle/fast_recovery_area/$DB_SID
      mv /u02/app/oracle/oradata/$DB_SID/cntrlORCLCDB.dbf /u02/app/oracle/oradata/$DB_SID/cntrl${DB_SID}.dbf
      mv /u03/app/oracle/fast_recovery_area/$DB_SID/cntrlORCLCDB2.dbf /u03/app/oracle/fast_recovery_area/$DB_SID/cntrl${DB_SID}2.dbf

  # make links
      cd /u02/app/oracle/oradata/
      ln -s $DB_SID ORCLCDB

  # change SID
      export ORACLE_SID=$DB_SID

  # db setup
  # enable archivelog + change global name + create spfile
      NEW_ORA=/u01/app/oracle/product/12.2.0/dbhome_1/dbs/init$DB_SID.ora
      sqlplus / as sysdba 2>&1 <<EOF
      create spfile from pfile='$NEW_ORA';
      startup mount;
      alter database open resetlogs;
      alter database rename global_name to $DB_SID.$DB_DOMAIN;
      show parameter spfile;
      show parameter encrypt_new_tablespaces;
      alter user sys identified by "$DB_PASSWD";
      alter user system identified by "$DB_PASSWD";
      exit;
EOF

  else
  # db setup
  # enable archivelog + change global name + create spfile
      NEW_ORA=/u01/app/oracle/product/12.2.0/dbhome_1/dbs/init$DB_SID.ora
      sqlplus / as sysdba 2>&1 <<EOF
      create spfile from pfile='$NEW_ORA';
      startup;
      alter database rename global_name to $DB_SID.$DB_DOMAIN;
      show parameter spfile;
      show parameter encrypt_new_tablespaces;
      alter user sys identified by "$DB_PASSWD";
      alter user system identified by "$DB_PASSWD";
      exit;
EOF
  fi

  # create orapw
  echo "update password"
  echo "$DB_PASSWD" | orapwd file=/u01/app/oracle/product/12.2.0/dbhome_1/dbs/orapw$DB_SID

  # create pdb
  echo "create pdb : $DB_PDB"
  sqlplus / as sysdba 2>&1 <<EOF
    create pluggable database $DB_PDB ADMIN USER sys1 identified by "$DB_PASSWD"
    default tablespace users
      datafile '/u02/app/oracle/oradata/ORCLCDB/orclpdb1/users01.dbf'
      size 10M reuse autoextend on maxsize unlimited
      file_name_convert=('/u02/app/oracle/oradata/ORCL/pdbseed','/u02/app/oracle/oradata/ORCLCDB/orclpdb1');
    alter pluggable database $DB_PDB open;
    alter pluggable database all save state;
    exit;
EOF

  if [[ ${dbrelarr[0]} == 12 && ${dbrelarr[1]} > 1 ]] || [[ ${dbrelarr[0]} > 12 ]];
  then
    echo "Reset Database parameters"
    sqlplus / as sysdba 2>&1 <<EOF
      alter system set encrypt_new_tablespaces=ddl scope=both;
      exit;
EOF
  fi
else
  echo "startup database instance"
  sqlplus / as sysdba 2>&1 <<EOF
    startup;
    exit;
EOF
fi

# custom scripts on start up
# echo "====> checking for custom scripts on startup..."
# if [ ! "$(ls -A /home/oracle/setup/custom_scripts/*.sql)" ]
# then
#     echo "/home/oracle/setup/custom_scripts is empty!"
# else
#     echo "/home/oracle/setup/custom_scripts is not empty"
# for filename in /home/oracle/setup/custom_scripts/*.sql; do
#     echo "Executing file $filename..."
#     sqlplus / as sysdba 2>&1 <<EOF
#           @$filename;
#           exit;
# EOF
# done
# fi


## db network set
# sqlnet.ora
SQLNET_ORA=$TNS_ADMIN/sqlnet.ora
echo "NAME.DIRECTORY_PATH= {TNSNAMES, EZCONNECT, HOSTNAME}" >> $SQLNET_ORA
echo "SQLNET.EXPIRE_TIME = 10" >> $SQLNET_ORA
echo "SSL_VERSION = 1.0" >> $SQLNET_ORA
# listener.ora
LSNR_ORA=$TNS_ADMIN/listener.ora
echo "LISTENER = \
  (DESCRIPTION_LIST = \
    (DESCRIPTION = \
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) \
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521)) \
    ) \
  ) \
\
" >> $LSNR_ORA
echo "DIAG_ADR_ENABLED = off"  >> $LSNR_ORA
echo "SSL_VERSION = 1.0"  >> $LSNR_ORA
# tnsnames.ora
TNS_ORA=$TNS_ADMIN/tnsnames.ora
echo "$DB_SID = \
  (DESCRIPTION = \
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) \
    (CONNECT_DATA = \
      (SERVER = DEDICATED) \
      (SERVICE_NAME = $DB_SID.$DB_DOMAIN) \
    ) \
  ) \
" >> $TNS_ORA
echo "$DB_PDB = \
  (DESCRIPTION = \
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521)) \
    (CONNECT_DATA = \
      (SERVER = DEDICATED) \
      (SERVICE_NAME = $DB_PDB.$DB_DOMAIN) \
    ) \
  ) \
" >> $TNS_ORA




echo "start listener"
cmd_output=$(lsnrctl start)
cmd_output=$(lsnrctl services)
echo "Output:\n\n"
echo "$cmd_output"

# clean
unset DB_PASSWD
history -w
history -c

echo ""
echo "DONE!"

#  echo "====> create my_dump_dir"
 mkdir -p /u01/app/oracle/admin/ORCL/dpdump/my_dump_dir/
#  echo "====> copy HLR.dmp to my_dump_dir"
 #cp /home/oracle/setup/custom_scripts/HLR.dmp /u01/app/oracle/admin/ORCL/dpdump/my_dump_dir/

# end
