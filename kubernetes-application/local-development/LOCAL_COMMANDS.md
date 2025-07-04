# Flask E-commerce Local Development Commands

## View application logs
docker-compose -f docker-compose-local.yml logs -f

## Check container status
docker-compose -f docker-compose-local.yml ps

## Stop the application
.\local-dev.ps1 -Down

## Restart the application
.\local-dev.ps1

## Rebuild and restart
.\local-dev.ps1 -Build

## View only Flask app logs
docker-compose -f docker-compose-local.yml logs -f flask-ecommerce

## Execute commands inside the container
docker-compose -f docker-compose-local.yml exec flask-ecommerce bash

## Access the database (if SQLite browser is available)
docker-compose -f docker-compose-local.yml exec flask-ecommerce ls -la /app/data/
