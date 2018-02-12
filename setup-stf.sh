ANDROID_DIR=/root/.android
if [ -f ${ANDROID_DIR}/stftoken ] ; then
  export STF_TOKEN=$(cat ${ANDROID_DIR}/stftoken)
fi
if [ -f ${ANDROID_DIR}/stfurl ] ; then
  export STF_URL=$(cat ${ANDROID_DIR}/stfurl)
fi
