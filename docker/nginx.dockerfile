FROM nginx:stable

ARG UID
ARG GID
ARG GROUPNAME
ARG USERNAME

ENV GROUPNAME=${GROUPNAME}
ENV USERNAME=${USERNAME}
ENV UID=${UID}
ENV GID=${GID}

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

#RUN addgroup -g ${GID} --system ${GROUPNAME}
#RUN adduser -G ${GROUPNAME} --system -D -s /bin/sh -u ${UID} ${USERNAME}
#RUN adduser --group ${GROUPNAME} --system --no-create-home -D --shell /bin/sh --uid ${UID} ${USERNAME}
RUN adduser --system --ingroup ${GROUPNAME} --no-create-home --home /nonexistent --gecos ${GROUPNAME} --shell /bin/sh --uid ${UID} ${USERNAME}
RUN mkdir -p /var/www/html
RUN chown -R ${USERNAME}:${GROUPNAME} /var/www/html

COPY --chmod=0644 "./docker/nginx/certs/cert.crt" "/etc/nginx/ssl/cert.crt"
COPY --chmod=0644 "./docker/nginx/certs/key.pem" "/etc/nginx/ssl/key.pem"
ADD ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

EXPOSE 80 443