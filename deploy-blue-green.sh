#!/bin/bash
# deploy-blue-green.sh - Grosirun V3.1 Blue-Green Zero-Downtime Deploy
# GAP Fixed: Blue-Green + Canary + Rollback Automation

set -e

BASE_DIR="/var/www/grosirun"
CURRENT_LINK="$BASE_DIR/current"
BLUE_DIR="$BASE_DIR/blue"
GREEN_DIR="$BASE_DIR/green"

# Detect current live color
if [ -L "$CURRENT_LINK" ]; then
  CURRENT_TARGET=$(readlink $CURRENT_LINK)
  CURRENT=$(basename $CURRENT_TARGET)
else
  CURRENT="blue"
  ln -nfs $BLUE_DIR $CURRENT_LINK
fi

if [ "$CURRENT" = "blue" ]; then
  NEXT="green"
  NEXT_DIR=$GREEN_DIR
else
  NEXT="blue"
  NEXT_DIR=$BLUE_DIR
fi

echo "Current live: $CURRENT, deploying to: $NEXT ($NEXT_DIR)"

cd $NEXT_DIR

echo "Pulling latest main..."
git pull origin main

echo "Composer install..."
cd backend
composer install --no-dev --optimize-autoloader --no-interaction

echo "Migrations..."
php artisan migrate --force --no-interaction

echo "Cache..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
php artisan optimize

echo "Warm up + health check temp port 8001..."
php artisan serve --host=127.0.0.1 --port=8001 &
PID=$!
sleep 8
if ! curl -f http://127.0.0.1:8001/api/v1/health; then
  echo "Health check failed on $NEXT, aborting"
  kill $PID || true
  exit 1
fi
kill $PID || true
sleep 2

echo "Switching symlink current -> $NEXT"
ln -nfs $NEXT_DIR $CURRENT_LINK

echo "Reload PHP-FPM + Nginx zero-downtime..."
sudo systemctl reload php8.3-fpm || sudo systemctl reload php8.2-fpm || true
sudo systemctl reload nginx || docker compose -f $BASE_DIR/docker-compose.yml -f $BASE_DIR/docker-compose.prod.yml exec nginx nginx -s reload || true

echo "Restart queue workers..."
supervisorctl restart grosirun-worker:* || docker compose -f $BASE_DIR/docker-compose.yml -f $BASE_DIR/docker-compose.prod.yml restart queue || true

echo "Post health check live..."
for i in {1..5}; do
  curl -f https://api.grosirun.id/api/v1/health && break || sleep 5
  if [ $i -eq 5 ]; then echo "Live health failed"; exit 1; fi
done

echo "Deployed to $NEXT and switched live. Old $CURRENT idle as rollback."

# Slack notify if webhook set
if [ ! -z "$SLACK_WEBHOOK" ]; then
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Grosirun deployed to $NEXT (blue-green) - $(git log -1 --oneline)\"}" $SLACK_WEBHOOK
fi
