# Laravel Docker Boilerplate - LEMP-Stack

## Enthaltene Services

- Nginx
- PHP-FPM
- Mysql
- Supervisor
- Cron


## Repository Struktur

```yaml
- src/                  # Project Files: muss erst erstellt werden!
- docker/               # Docker Konfiguration
- .dockerignore         # was Docker ignorieren soll
- .gitignore            # was Git ignorieren soll
- docker-compose.yml    # Docker Container Services Konfiguration
- README.MD             # Projekt Beschreibung: kann geändert werden
```

### 1. clone repository
```bash
git clone git@github.com:KarstenKuehn/Laravel-Docker-Lemp-Stack.git
```

### 2. change remote url
ersetze die git origin remote url mit deiner Repository Url:
```bash
git remote set-url origin <new-git-repository-url>
```

### 3. modify .gitignore
lösche den `src/` Eintrag in der [.gitignore](.gitignore):
```text
src/
```

### 4. adaption
passe alles so an, wie und was du auch immer brauchst!