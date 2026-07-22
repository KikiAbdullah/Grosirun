#!/bin/bash
# rollback.sh - Grosirun V3.1 Rollback Automation - GAP Fixed

set -e

BASE_DIR="/var/www/grosirun"
CURRENT_LINK="$BASE_DIR/current"
BLUE_DIR="$BASE_DIR/blue"
GREEN_DIR="$BASE_DIR/green"

CURRENT_TARGET=$(readlink $CURRENT_LINK)
CURRENT=$(basename $CURRENT_TARGET)

if [ "$CURRENT" = "blue" ]; then
  ROLLBACK="green"
  ROLLBACK_DIR=$GREEN_DIR
else
  ROLLBACK="blue"
  ROLLBACK_DIR=$BLUE_DIR
fi

echo "Rolling back from $CURRENT to $ROLLBACK ($ROLLBACK_DIR)"

cd $ROLLBACK_DIR/backend

echo "Config cache rollback version..."
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

echo "Health check rollback version temp port 8001..."
php artisan serve --host=127.0.0.1 --port=8001 &
PID=$!
sleep 8
if ! curl -f http://127.0.0.1:8001/api/v1/health; then
  echo "Rollback health check failed!"
  kill $PID || true
  exit 1
fi
kill $PID || true

echo "Switching symlink current -> $ROLLBACK"
ln -nfs $ROLLBACK_DIR $CURRENT_LINK

echo "Reload FPM Nginx..."
sudo systemctl reload php8.3-fpm || sudo systemctl reload php8.2-fpm || true
sudo systemctl reload nginx || true

echo "Restart queue..."
supervisorctl restart grosirun-worker:* || true

echo "Post health..."
curl -f https://api.grosirun.id/api/v1/health

if [ ! -z "$SLACK_WEBHOOK" ]; then
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Grosirun ROLLBACK to $ROLLBACK automated - $(date)\"}" $SLACK_WEBHOOK
fi

echo "Rollback done to $ROLLBACK"
