# Use PHP 8.3 FPM Alpine as the base image
FROM docker.io/library/php:8.3-fpm-alpine

# Make log file
RUN touch /var/log/error_log

# Copy configuration files and fix permissions
ADD ./php/www.conf /usr/local/etc/php-fpm.d/www.conf
RUN addgroup -g 1000 wp && adduser -G wp -g wp -s /bin/sh -D wp
RUN mkdir -p /var/www/html
RUN chown wp:wp /var/www/html
WORKDIR /var/www/html

# Install necessary PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql bcmath exif && \
  docker-php-ext-enable pdo_mysql bcmath exif

# Install ImageMagick and Imagick PHP extension
RUN set -ex \
  && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
  && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
  && pecl install imagick \
  && docker-php-ext-enable imagick \
  && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
  && apk del .phpize-deps

# Install GD (graphics library)
RUN apk add --no-cache libpng libpng-dev && \
  docker-php-ext-install gd && \
  apk del libpng-dev

# Install ZIP extension
RUN apk add --no-cache libzip-dev && \
  docker-php-ext-install zip

# Install ICU and INTL extension for internationalization
RUN apk add --no-cache icu-dev && \
  docker-php-ext-configure intl && \
  docker-php-ext-install intl && \
  docker-php-ext-enable intl

# Install WP-CLI (WordPress CLI)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  mv wp-cli.phar /usr/local/bin/wp

# Clean up apk cache
RUN rm -rf /var/cache/apk/*

# Add mkcert's root certificate into the container
ADD ./rootCA.pem /usr/local/share/ca-certificates/my-cert.crt

# Update certificate authorities
RUN cat /usr/local/share/ca-certificates/my-cert.crt >> /etc/ssl/certs/ca-certificates.crt && \
  apk --no-cache add \
  curl
