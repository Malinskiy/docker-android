#!/usr/bin/env bash

echo 'Checking container limits'
source /container-limits
MAX_HEAP=$(echo $CONTAINER_MAX_MEMORY | awk '{$1=($1/(1024^2))/4; printf "%.0f", $1;}')
export _JAVA_OPTIONS="-Xmx$(($MAX_HEAP))m"
echo "Set _JAVA_OPTIONS=$_JAVA_OPTIONS"

echo "Adding org.gradle.jvmargs"
echo "org.gradle.jvmargs=-Xmx$(($MAX_HEAP))m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" >> ~/.gradle/gradle.properties
echo "org.gradle.workers.max=$(($CONTAINER_CORE_LIMIT))" >> ~/.gradle/gradle.properties

source /etc/profile.d/stf.sh
echo "Set STF_TOKEN: ${STF_TOKEN}"
echo "Set STF_URL: ${STF_URL}"

RUBY_ENV=/usr/local/rvm/scripts/rvm
if [ -f ${RUBY_ENV} ] ; then
  echo "Setup Ruby environment"
  source ${RUBY_ENV}
fi
