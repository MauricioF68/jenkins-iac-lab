#!/bin/bash

# Recibimos el nombre del archivo de plugins como argumento
PLUGIN_FILE=$1

# Ejecutamos el instalador oficial de Jenkins
jenkins-plugin-cli --plugin-file "$PLUGIN_FILE"