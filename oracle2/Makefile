TARGET = oracle-db
V12=container-registry.oracle.com/database/enterprise:12.2.0.1
V11=oraclelinux:7-slim
#registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g

all: build
	
build:
ifeq ($(v), v11)
	./buildContainerImage.sh -v 11.2.0.2 -i -x 
#docker build --build-arg arg=$(V11) -t "$(TARGET)" .
else
	docker build --build-arg arg=$(V12) -t "$(TARGET)" .
endif


.PHONY: all build
