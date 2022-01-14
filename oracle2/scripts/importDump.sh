
 ls /u01/app/oracle/admin/ORCL/dpdump/my_dump_dir/
 echo "====> creating user and tablespace"
 sqlplus system/Oradoc_db1@localhost:1521/hlrdb.protei.ru 2>&1 <<EOF
      create user HLRDB identified by hlr;
      grant dba,connect to HLRDB;
      create user SUPPORTNL identified by hlr;
      CREATE TABLESPACE TS_HLR DATAFILE 'tbs_perm_01.dat' SIZE 20M REUSE AUTOEXTEND ON NEXT 10M MAXSIZE 1024M ONLINE;
      CREATE OR REPLACE DIRECTORY MY_DUMP_DIR as '/u01/app/oracle/admin/ORCL/dpdump/my_dump_dir/';
      GRANT READ, WRITE ON DIRECTORY MY_DUMP_DIR to HLRDB;
      CREATE ROLE RO_ROLE;
      exit;
EOF


echo "====> loading BD dump file"
impdp HLRDB/hlr@localhost:1521/hlrdb.protei.ru directory=my_dump_dir dumpfile=HLR.dmp full=y logfile=expdpEMP_DEPT.log


