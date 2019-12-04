#!/bin/sh -u

# 設定ファイル読込
. ./env.txt

# 引数validate
# 第1引数
export tableName=$1
export schema=$2

echo 'export oracle record'
sqlplus -S -M 'csv on quote off' ${schema}/${ORACLE_PASSWORD}@${ORACLE_HOST}:${ORACLE_PORT}/${ORACLE_SERVER_NAME} <<-SQL > ${tableName}.csv
SET HEADING OFF FEEDBACK OFF
SELECT * FROM ${tableName};
SQL

export csvCount=`cat ${tableName}.csv | grep ',' | wc -l`

if [[ ${csvCount} -lt 2 ]]; then
  echo ${csvCount}
  end
fi

echo 'import mysql record'

MYSQL_PWD=${MYSQL_PASSWORD} mysql -u ${MYSQL_USERNAME} -A -h ${MYSQL_HOST} --local_infile=1 <<-SQL
use ${schema};
truncate ${tableName};
LOAD DATA LOCAL INFILE './${tableName}.csv' INTO TABLE ${tableName} FIELDS TERMINATED BY ',' ENCLOSED BY '"';
SQL
