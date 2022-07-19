FROM php:8.1-fpm

WORKDIR /var/www/html

RUN docker-php-ext-install pdo pdo_mysql

RUN apt-get update  \
    && apt-get install -y \
    supervisor \
    cron

#####################################
# Laravel Schedule Cron Job:
#####################################
RUN mkdir -p /var/log/cron
COPY --chmod=0644 ./docker/cron/laravel-scheduler /etc/cron.d/laravel-scheduler
RUN crontab /etc/cron.d/laravel-scheduler

#####################################
# SUPERVISOR CONF:
####################################
COPY --chmod=0644 ./docker/supervisor/conf.d/laravel-worker.conf /etc/supervisor/conf.d/laravel-worker.conf
COPY --chmod=0644 ./docker/supervisor/supervisord.conf /etc/supervisor/supervisord.conf