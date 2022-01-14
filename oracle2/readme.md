```
oracle-db
│
└───dump     // дамп БД
└───scripts  // скрипты 
│    └───checkHealthStatus.sh // ожидание запуска контейнера
│    └───importDump.sh // импорт дампа БД
│    └───runSql.sh // запуск sqlplus
└───configDBora.sh  // начальная конфигурация
└───Dockerfile
└───Makefile
```

## Build image
```sh
make v=v11
```
> Note: `v=v11` если необходима 11 версия oracle, по дефолту - 12

## Run container
```sh
docker run -it --name oracle-db-container -p :1521 -p :5500 -e DB_SID=HLR -e DB_PDB=hlrdb  -e DB_DOMAIN=protei.ru oracle-db
```

## Start health check script
```sh
./scripts/checkHealthStatus.sh
```

## Run commands inside container
```sh
docker exec -it oracle-db-container /bin/bash
```

## Start import DB dump file
```sh
./importDump.sh
```
## Start sqlplus
```sh
./runSql.sh
```
or
```sh
sqlplus HLR/sql@localhost:1521/hlrdb.protei.ru
```
> Note: USER=`HLR`, password=`sql`