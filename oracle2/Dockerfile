ARG arg

FROM $arg as builder

ENV ORACLE_ROOT_PASSWORD=elephant \
    ORACLE_USER=user \
    ORACLE_PASSWORD=sql \
    ORACLE_DATABASE=HLR \
    ORACLE_INITDB_SKIP_TZINFO=1 \
    SCRIPTS_DIR=/u01/scripts    \
    USER_DB=HLR  \
    USER_DB_PWD=hlr

FROM $arg

RUN mkdir -p /home/oracle/setup/custom_scripts
WORKDIR /home/oracle/setup/custom_scripts

COPY configDBora.sh /home/oracle/setup/

#COPY sql/* /home/oracle/setup/custom_scripts
COPY scripts/* /home/oracle/setup/custom_scripts/

COPY dump/HLR.dmp /home/oracle/setup/custom_scripts/
USER root
RUN chmod 777 /home/oracle/setup/custom_scripts/HLR.dmp
USER oracle
