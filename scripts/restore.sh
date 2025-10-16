#!/bin/bash
# restore.sh : restauration d'une sauvegarde
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <chemin_vers_la_sauvegarde>"
  exit 1
fi

BACKUP_DIR="$1"
echo "🔹 Restauration depuis $BACKUP_DIR ..."

for VOL in mariadb_data glpi_data influxdb_data grafana_data mongodb_data; do
    echo "⚡ Nettoyage du volume $VOL"
    docker run --rm -v "$VOL":/data alpine sh -c "rm -rf /data/*"
done

# Restauration
docker run --rm -v mariadb_data:/data -v "$BACKUP_DIR":/backup alpine \
    sh -c "tar xzf /backup/mariadb.tar.gz -C /data"
docker run --rm -v glpi_data:/data -v "$BACKUP_DIR":/backup alpine \
    sh -c "tar xzf /backup/glpi_files.tar.gz -C /data"
docker run --rm -v influxdb_data:/data -v "$BACKUP_DIR":/backup alpine \
    sh -c "tar xzf /backup/influxdb.tar.gz -C /data"
docker run --rm -v grafana_data:/data -v "$BACKUP_DIR":/backup alpine \
    sh -c "tar xzf /backup/grafana.tar.gz -C /data"
docker run --rm -v mongodb_data:/data -v "$BACKUP_DIR":/backup alpine \
    sh -c "tar xzf /backup/mongodb.tar.gz -C /data"

echo "✅ Restauration terminée."
