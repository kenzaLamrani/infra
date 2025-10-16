#!/bin/bash
# pra.sh : PRA complet pour tout le stack
set -e

echo "🚀 PRA démarrage"

# 1️⃣ Stopper les services
echo "🔹 Arrêt des containers..."
docker-compose down

# 2️⃣ Restaurer (optionnel)
if [ -n "$1" ]; then
  $(dirname "$0")/restore.sh $1
else
  echo "⚡ Aucun backup fourni, restauration ignorée"
fi

# 3️⃣ Lancer les services
echo "🔹 Démarrage des containers..."
docker-compose up -d

# 4️⃣ Vérifier l'état
echo "🔹 Vérification de l'état des containers..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "✅ PRA terminé. Tous les services devraient être opérationnels."
