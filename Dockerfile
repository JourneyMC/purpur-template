FROM eclipse-temurin:17-alpine

# Install required packages
RUN apk add --no-cache \
    bash \
    gettext \
    tini

# UID & GID for non-root user
ARG uid=10001
ARG gid=10001

# Non-root user for security purposes.
#
# A UID/GID above 10,000 is less likely to 
# map to a more privileged user on the host
# in the case of a container breakout.
RUN addgroup --gid ${uid} --system nonroot \
 && adduser --uid ${gid} --system \
 --ingroup nonroot --disabled-password nonroot

# Initial and max heap size for the java application
ARG heap_size=4G
ENV HEAP_SIZE=$heap_size

# Aikar JVM Flags
ARG java_tool_options="-Xmx${HEAP_SIZE} -Xms${HEAP_SIZE} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 \
-XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 \
-XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 \
-XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 \
-XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 \
-Dusing.aikars.flags=mcflags.emc.gs -Daikars.new.flags=true -Dcom.mojang.eula.agree=true"
ENV JAVA_TOOL_OPTIONS=$java_tool_options

# URL for the Purpur jar
ARG purpur_version=1.18.1
ENV PURPUR_JAR_URL=https://api.purpurmc.org/v2/purpur/${purpur_version}/latest/download

# Add the Purpur jar
ADD --chown=nonroot:nonroot ${PURPUR_JAR_URL} /opt/purpur/purpur.jar

# Entrypoint
ENTRYPOINT ["/sbin/tini", "--", "java", "-jar", "/opt/purpur/purpur.jar", "nogui", "--world-container", "/worlds"]

# Copy scripts
COPY --chown=nonroot:nonroot scripts/ /usr/local/bin/

# Copy secrets
ARG secrets_path=/.secrets
COPY --chown=nonroot:nonroot secrets/ $secrets_path

# Copy server files
ARG data_path=/home/nonroot/minecraft
COPY --chown=nonroot:nonroot server/ $data_path

# Create data dirs
ARG worlds_data_path=/worlds
ARG plugin_data_path=/plugin_data
RUN mkdir -p $plugin_data_path $worlds_data_path $data_path/logs \
  && chown -R nonroot:nonroot $plugin_data_path $worlds_data_path $data_path/logs

# Switch user to run as non-root
USER nonroot

# Substitute envvars
RUN bash /usr/local/bin/substitute_envvars.sh ${data_path} ${secrets_path}

# Persistent data
VOLUME $plugin_data_path $worlds_data_path $data_path/logs

# Initialize plugin data
RUN bash /usr/local/bin/init_plugindata.sh ${data_path}/plugins ${plugin_data_path}

WORKDIR $data_path
