#!/bin/sh
#
# Author: Ramon Antonio Parada <ramon@bigpress.net>
#

ER="$2"
PSQL="psql -q -n -A -t"
SCHEMES="'public'"
DB="pezca_web_test"
USER="ozono"
#if [ -z "$1" ]; then
#        echo "Something like: ./grant mydatabase myuser | psql mydatabase"
#        exit
#fi

#if [ -z "$2" ]; then
#        USER="$1"
#fi

echo "-- Granting rights on $DB to $USER ($SCHEMES)"
# tables
# select 'grant all on '||schemaname||'.'||tablename||' to ozono;' from pg_tables where schemaname in ('public') order by schemaname, tablename;
Q="select 'grant all on '||schemaname||'.'||tablename||' to \\\"$USER\\\";' from pg_tables where schemaname in ($SCHEMES);"
echo $Q
filename="/tmp/tmp_$DB_$USER_tables"
$PSQL -c "$Q" "$DB" -e >> $filename 
cat $filename | psql $DB

# views
Q="select 'grant all on '||schemaname||'.'||viewname||' to \\\"$USER\\\";' from pg_views where schemaname in ($SCHEMES);"
filename="/tmp/tmp_$DB_$USER_views"
$PSQL -c "$Q" "$DB" -e >> $filename
cat $filename | psql $DB

# sequences
Q="select 'grant all on function '||n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||') to \\\"$USER\\\";' from pg_proc p, pg_namespace n where n.oid = p.pronamespace and n.nspname in ($SCHEMES);"
filename="/tmp/tmp_$DB_$USER_sequences"
$PSQL -c "$Q" "$DB" -e >> $filename 
cat $filename | psql $DB

# functions
Q="select 'grant all on '||n.nspname||'.'||c.relname||' to \\\"$USER\\\";' from pg_class c, pg_namespace n where n.oid = c.relnamespace and c.relkind IN ('S') and n.nspname in ($SCHEMES);"
filename="/tmp/tmp_$DB_$USER_functions"
$PSQL -c "$Q" "$DB" -e >> $filename 
cat $filename | psql $DB 
