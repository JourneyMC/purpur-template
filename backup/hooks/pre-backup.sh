#!/bin/sh

mysqldump --host ${MYSQL_HOST:-db} --port ${MYSQL_PORT:-3306} --all-databases > /data/$(hostname)_mysqldump.sql
/usr/local/bin/rcon-cli save-off
