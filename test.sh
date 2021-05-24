#!/bin/bash
DATABASE=
HOST=
SCHEMA=
PORT=5432
USER="postgres"
PASSWORD=
TESTS="/t/*.sql"

function usage() { echo "Usage: $0 -h host -d database -p port -u username -w password -t tests -s schema" 1>&2; exit 1; }

while getopts d:h:p:u:w:b:n:t:s: OPTION
do
  case $OPTION in
    d)
      DATABASE=$OPTARG
      ;;
    h)
      HOST=$OPTARG
      ;;
    p)
      PORT=$OPTARG
      ;;
    u)
      USER=$OPTARG
      ;;
    w)
      PASSWORD=$OPTARG
      ;;
    t)
      TESTS=$OPTARG
      ;;
    s)
      SCHEMA=$OPTARG
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z $DATABASE ]] || [[ -z $HOST ]] || [[ -z $PORT ]] || [[ -z $USER ]] || [[ -z $TESTS ]] || [[ -z $SCHEMA ]]
then
  usage
  exit 1
fi

echo "Running tests: $TESTS"
# install pgtap
PGOPTIONS="-c search_path=$SCHEMA" PGPASSWORD=$PASSWORD psql -h $HOST -p $PORT -d $DATABASE -U $USER -f /pgtap/sql/pgtap.sql > /dev/null 2>&1

rc=$?
# exit if pgtap failed to install
if [[ $rc != 0 ]] ; then
  echo "pgTap was not installed properly. Unable to run tests!"
  exit $rc
fi
# run the tests
mkdir /output
#export JUNIT_OUTPUT_FILE=/output/pgtap.xml
PGPASSWORD=$PASSWORD  JUNIT_OUTPUT_FILE=/output/pgtap.xml pg_prove --harness TAP::Harness::JUnit -f -r --ext .sql -h $HOST -p $PORT -d $DATABASE -U $USER $TESTS
rc=$?

# exit with return code of the tests
exit $rc
