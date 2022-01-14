TARGET = oracle-db-check
V12=container-registry.oracle.com/database/enterprise:12.2.0.1
V11=oraclelinux:7-slim
#registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g

all: build
	
build:
ifeq ($(v), v11)
	./buildContainerImage.sh -v 11.2.0.2 -i -x 
#docker build --build-arg arg=$(V11) -t "$(TARGET)" .
else
	docker build --no-cache=true --build-arg arg=$(V12) --build-arg DB_EDITION=xe -t "$(TARGET)" -f Dockerfile.xe .
endif


.PHONY: all build
