#!/bin/bash

/usr/local/bin/init_plugindata.sh ${DATA_PATH}/plugins ${PLUGIN_DATA_PATH}

exec su-exec nonroot:nonroot /sbin/tini -- java -Xms"${HEAP_SIZE}" -Xmx"${HEAP_SIZE}" -jar /opt/purpur/purpur.jar nogui --world-container ${WORLDS_DATA_PATH}
