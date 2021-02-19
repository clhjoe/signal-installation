#!/bin/bash
# ====variables====

SIGNAL_FOLDER=Signal-Server
SIGNAL_CONFIG=$SIGNAL_FOLDER/service/config/config.yml
java -jar $SIGNAL_FOLDER/service/target/TextSecureServer-3.21.jar server $SIGNAL_CONFIG