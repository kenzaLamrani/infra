#!/bin/bash
# pra.sh : Plan de Reprise d'Activité (PRA)
# Usage : ./pra.sh /chemin/vers/backup
set -e

BACKUP_DIR="$1"

if [ -z "$BACKUP_DIR" ]; then
    echo "❌ Veuillez fournir le dossier de backup."
    exit 1
fi

echo "🚀 PRA démarrage"

echo "🔹 Arrêt des containers..."
docker compose -f ../docker-compose.yml down

echo "🔹 Restauration depuis $BACKUP_DIR ..."

# Fonction pour restaurer un volume
restore_volume() {
    local VOLUME_NAME=$1
    local BACKUP_FILE=$2
    local TARGET_PATH=$3

    echo "⚡ Restauration du volume $VOLUME_NAME ..."
    docker run --rm \
        -v "${VOLUME_NAME}:${TARGET_PATH}" \
        -v "${BACKUP_DIR}:/backup" \
        alpine \
        sh -c "rm -rf ${TARGET_PATH}/* && tar xzf /backup/${BACKUP_FILE} -C ${TARGET_PATH}"
}

# MariaDB
restore_volume mariadb_data mariadb.tar.gz /var/lib/mysql

# GLPI files
restore_volume glpi_data glpi_files.tar.gz /var/www/html/glpi

# InfluxDB
restore_volume influxdb_data influxdb.tar.gz /var/lib/influxdb

# Grafana
restore_volume grafana_data grafana.tar.gz /var/lib/grafana

# MongoDB
restore_volume mongodb_data mongodb.tar.gz /data/db

echo "🔹 Démarrage des containers..."
docker compose -f ../docker-compose.yml up -d

echo "✅ PRA terminé"
