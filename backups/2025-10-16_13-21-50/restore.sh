#!/bin/sh
# Script de restauration - Généré le 2025-10-16T13:21:50Z

echo "╔════════════════════════════════════════════════════════════╗"
echo "║              🔄 RESTAURATION DES BACKUPS                    ║"
echo "╚════════════════════════════════════════════════════════════╝"

BACKUP_DIR="/ansible/backups/2025-10-16_13-21-50"

# Fonction pour restaurer les volumes
restore_volumes() {
    echo "📦 Restauration des volumes..."
        if [ -f "$BACKUP_DIR/volumes/glpi_data.tar.gz" ]; then
        echo "  → Restauration de glpi_data..."
        docker run --rm \
            -v glpi_data:/restore \
            -v "$BACKUP_DIR/volumes:/backup:ro" \
            alpine sh -c "cd /restore && tar xzf /backup/glpi_data.tar.gz"
        echo "  ✅ glpi_data restauré"
    fi
        if [ -f "$BACKUP_DIR/volumes/grafana_data.tar.gz" ]; then
        echo "  → Restauration de grafana_data..."
        docker run --rm \
            -v grafana_data:/restore \
            -v "$BACKUP_DIR/volumes:/backup:ro" \
            alpine sh -c "cd /restore && tar xzf /backup/grafana_data.tar.gz"
        echo "  ✅ grafana_data restauré"
    fi
        if [ -f "$BACKUP_DIR/volumes/influxdb_data.tar.gz" ]; then
        echo "  → Restauration de influxdb_data..."
        docker run --rm \
            -v influxdb_data:/restore \
            -v "$BACKUP_DIR/volumes:/backup:ro" \
            alpine sh -c "cd /restore && tar xzf /backup/influxdb_data.tar.gz"
        echo "  ✅ influxdb_data restauré"
    fi
        if [ -f "$BACKUP_DIR/volumes/mariadb_data.tar.gz" ]; then
        echo "  → Restauration de mariadb_data..."
        docker run --rm \
            -v mariadb_data:/restore \
            -v "$BACKUP_DIR/volumes:/backup:ro" \
            alpine sh -c "cd /restore && tar xzf /backup/mariadb_data.tar.gz"
        echo "  ✅ mariadb_data restauré"
    fi
        if [ -f "$BACKUP_DIR/volumes/mongodb_data.tar.gz" ]; then
        echo "  → Restauration de mongodb_data..."
        docker run --rm \
            -v mongodb_data:/restore \
            -v "$BACKUP_DIR/volumes:/backup:ro" \
            alpine sh -c "cd /restore && tar xzf /backup/mongodb_data.tar.gz"
        echo "  ✅ mongodb_data restauré"
    fi
    }

# Fonction pour restaurer MariaDB
restore_mariadb() {
    if [ -f "$BACKUP_DIR/databases/mariadb_dump.sql.gz" ]; then
        echo "🗄️  Restauration de MariaDB..."
        read -p "Mot de passe root MySQL: " MYSQL_PASSWORD
        gunzip < "$BACKUP_DIR/databases/mariadb_dump.sql.gz" | \
            docker exec -i ansible-mariadb-1 mysql -u root -p"$MYSQL_PASSWORD"
        echo "✅ MariaDB restauré"
    fi
}

# Fonction pour restaurer InfluxDB
restore_influxdb() {
    if [ -f "$BACKUP_DIR/databases/influxdb_backup.tar.gz" ]; then
        echo "📊 Restauration d'InfluxDB..."
        docker exec ansible-influxdb-1 sh -c "cd /tmp && \
            tar xzf - && \
            influx restore /tmp/influxdb_backup -portable" \
            < "$BACKUP_DIR/databases/influxdb_backup.tar.gz"
        echo "✅ InfluxDB restauré"
    fi
}

# Fonction pour restaurer MongoDB
restore_mongodb() {
    if [ -f "$BACKUP_DIR/databases/mongodb_dump.archive" ]; then
        echo "🍃 Restauration de MongoDB..."
        docker exec -i ansible-mongodb-1 mongorestore \
            --archive --gzip < "$BACKUP_DIR/databases/mongodb_dump.archive"
        echo "✅ MongoDB restauré"
    fi
}

# Menu principal
echo ""
echo "Que souhaitez-vous restaurer ?"
echo "1) Tout"
echo "2) Volumes uniquement"
echo "3) Bases de données uniquement"
echo "4) MariaDB uniquement"
echo "5) InfluxDB uniquement"
echo "6) MongoDB uniquement"
echo "0) Quitter"

read -p "Votre choix: " choice

case $choice in
    1)
        restore_volumes
        restore_mariadb
        restore_influxdb
        restore_mongodb
        ;;
    2) restore_volumes ;;
    3)
        restore_mariadb
        restore_influxdb
        restore_mongodb
        ;;
    4) restore_mariadb ;;
    5) restore_influxdb ;;
    6) restore_mongodb ;;
    0) exit 0 ;;
    *) echo "Choix invalide" ;;
esac

echo ""
echo "✨ Restauration terminée!"
