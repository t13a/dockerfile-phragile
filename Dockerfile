FROM composer AS builder

ARG PHRAGILE_REPOSITORY=${PHRAGILE_REPOSITORY:-https://github.com/wmde/phragile}
ARG PHRAGILE_BRANCH=${PHRAGILE_BRANCH:-3.0.0}

RUN git clone -b ${PHRAGILE_BRANCH} ${PHRAGILE_REPOSITORY} /phragile && \
    cd /phragile && \
    composer install

FROM php:7.0-fpm-alpine

RUN apk --no-cache add libmcrypt-dev nginx s6 tzdata && \
    docker-php-ext-install mcrypt pdo_mysql

COPY --from=builder /phragile /phragile
COPY /rootfs /

WORKDIR /

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "s6-svscan", "/s6" ]
