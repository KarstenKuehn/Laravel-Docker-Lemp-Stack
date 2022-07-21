# Docker LEMP-Stack für Laravel

## Enthaltene Services

- Nginx Webserver
- PHP-FPM
- Datenbank (Mysql)
- Laravel Queue (Supervisor)
- Laravel Schedule (Cron)


## Struktur

```yaml
- src/                  # Project Files: muss erst erstellt werden!
- docker/               # Docker Konfiguration
- .dockerignore         # was Docker ignorieren soll
- docker-compose.yml    # Docker Container Services Konfiguration
- README.MD             # Projekt Beschreibung: kann geändert werden
```


## 1. SSL Zertifikate für localhost erstellen
Es gibt 2 Optionen:
- [mkcert](#mkcert)
- [openssl](#openssl)

```bash
cd ./docker/nginx/certs
```

### 1.1. mkcert
[Dokumentation](https://github.com/FiloSottile/mkcert)

#### 1.1.1. Installation
```bash
sudo apt install libnss3-tools mkcert
```
#### 1.1.2. Verzeichnis
```bash
cd docker/nginx/certs/
```

#### 1.1.3. Zertifikate erzeugen
```bash
mkcert -key-file key.pem -cert-file cert.crt laravel-docker.localhost localhost 127.0.0.1 ::1
```

### 1.2. openssl
[Dokumentation](https://letsencrypt.org/de/docs/certificates-for-localhost/)
#### 1.2.1. Verzeichnis
```bash
cd docker/nginx/certs/
```

```bash
DOMAIN=localhost

openssl req -x509 -days 3650 -out localhost.crt -keyout localhost.key \
-newkey rsa:2048 -nodes -sha256 \
-subj /CN=${DOMAIN} -extensions EXT -config <( \
printf "[dn]\nCN=${DOMAIN}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:${DOMAIN}\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
```

### 1.3. Zertifikate im Hostsystem bekannt machen
#### 1.3.1. Linux
Zertifikat kopieren
```bash
sudo cp cert.crt  /usr/local/share/ca-certificates/localhost/cert.crt
```
und updaten
```bash
sudo update-ca-certificates
```

#### 1.3.2. MacOS
Öffne das Zertifikat mit einem Doppelklick und klicke in der Schlüsselbund-Verwaltung wähle `immer vertrauen`.
Speichern und fertig!


### 1.4. Domain lokal bekannt machen
```bash
sudo nano /etc/hosts
```
Zeilen eintragen und speichern
```text
127.0.0.1       laravel-docker.localhost localhost
::1             laravel-docker.localhost localhost
```

## 2. Laravel Neuinstallation
`src/` = Laravel
```bash
mkdir src/ && cd src/
```

### 2.1 Laravel Projekt erzeugen
```bash
docker compose run --rm composer create-project laravel/laravel .
```
### 2.2. Laravel Berechtigungen setzen
innerhalb von `src/`

#### 2.2.1 Laravel Konfiguration

passe deine `src/.env` Datei an:
```text
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
DB_ROOT_PASSWORD=secret
```

```bash
cd src/
```
rekursiv im `src` - Verzeichnis!

`Dateien`
```bash
sudo find . -type f -exec chmod 664 {} \; 
```

`Verzeichnisse`
```bash
sudo find . -type d -exec chmod 775 {} \; 
```

`Extras`
```bash
sudo chmod -R ug+rwx storage bootstrap/cache
```


## 3. Docker Container
`--env-file ./src/.env` aus der Laravel-Installation verwenden!

### 3.1. Container build & starten
```bash
docker compose --env-file ./src/.env up -d --build
```
### 3.2. Berechtigungen

#### 3.2.1. (Container) User anzeigen
```bash
docker exec -it nginx cat /etc/passwd
```

#### 3.2.2. (Container) Gruppen anzeigen 
```bash
docker exec -it nginx cat /etc/group
```
`www-data Group existiert`
```text
www-data:x:<group-id>:
```

#### 3.2.3. (Container) Berechtigungen setzen

```bash
docker exec -it nginx chgrp -R www-data /var/www/html/storage /var/www/html/bootstrap/cache
```

#### 3.2.4. (Container) GroupID anzeigen & prüfen
```bash
docker exec -it nginx ls -n /var/www/html
```

#### 3.2.5. (Host) GroupID anzeigen
```bash
ls -n src/
```
Die GroupId merken!

#### 3.2.6. (Host) Berechtigungen setzen

##### 3.2.6.1 Gruppen anzeigen
```bash
cat /etc/group
```
##### 3.2.6.2 Gruppe anlegen (sofern noch nicht vorhanden)
`mit GroupId`  
```bash
sudo addgroup --gid 100032 laravel-docker-nginx
```

##### 3.2.6.3 User zur neu angelegten Gruppe hinzufügen (sofern noch nicht vorhanden)
```bash
sudo adduser $USER laravel-docker-nginx
```

## 4. Container
### 4.1. Composer

```bash
docker compose --env-file ./src/.env run --rm composer <command>
```
`example`
```bash
docker compose --env-file ./src/.env run --rm composer install
```

### 4.2. Artisan
```bash
docker compose --env-file ./src/.env run --rm artisan <command>
```
`example`
```bash
docker compose --env-file ./src/.env run --rm artisan migrate:status
```


### 4.3. NPM (Container)
#### 4.3.1. Hinweis
`run` Optionen in der package.json beachten!

```bash
docker compose --env-file ./src/.env run --rm npm
```
```bash
docker compose --env-file ./src/.env run --rm npm <command>
```
#### 4.3.2. npm install
```bash
docker compose --env-file ./src/.env run --rm npm install
```
##### 4.3.3. npm kompilieren
```bash
docker compose --env-file ./src/.env run --rm npm run build
```
`oder`
```bash
docker compose --env-file ./src/.env run --rm npm run prod
```

### 5. Services
#### 5.1. Laravel-Scheduler
Der Service Cron-Daemon wird automatisch als Container gestartet.

#### 5.2. Laravel-Queue
Der Service Supervisor-Daemon wird automatisch als Container gestartet.

#### 5.3. Optionale Services
Für weitere Services einfach die `docker-compose.yml` erweitern.

`copy, paste & edit`

##### 5.3.1. phpmyadmin
```yaml
# Database management
phpmyadmin:
  image: phpmyadmin/phpmyadmin:latest
  container_name: "phpmyadmin"
  environment:
    - PMA_ARBITRARY=1
    - UPLOAD_LIMIT=10G
    - MEMORY_LIMIT=1G
    - MAX_EXECUTION_TIME=3600
    - HIDE_PHP_VERSION=true
    - PMA_HOST=database
    - PMA_USER=${DB_USERNAME}
    - PMA_PASSWORD=${DB_PASSWORD}
    - PMA_PORT=${DB_PORT}
  restart: always
  depends_on:
    - mysql
  ports:
    - 8888:80
  networks:
    - laravel
  
```
##### 5.3.2. mailhog (Email-Testing)
```yaml
mailhog:
  image: mailhog/mailhog:latest
  container_name: "mailhog"
  ports:
    - 1025:1025
    - 8025:8025
  networks:
    - laravel
  environment:
    - MH_STORAGE=maildir
    - MH_MAILDIR_PATH=maildir
  volumes:
    - mailhog:/home/mailhog:cached

```
Volumes erweitern
```yaml
volumes:
  mailhog:
```

##### 5.3.3. reverse proxy testing
```yaml
kommt noch...
```
