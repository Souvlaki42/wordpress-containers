# Use latest stable alpine nginx as the base image
FROM docker.io/library/nginx:stable-alpine

# Add config and local certs into the container
ADD ./nginx/default.conf /etc/nginx/conf.d/default.conf
ADD ./nginx/certs /etc/nginx/certs/self-signed

# Add mkcert's root certificate into the container
ADD ./rootCA.pem /usr/local/share/ca-certificates/my-cert.crt

# Update certificate authorities
RUN cat /usr/local/share/ca-certificates/my-cert.crt >> /etc/ssl/certs/ca-certificates.crt && \
  apk --no-cache add \
  curl

# Make /var/www/html
RUN mkdir -p /var/www/html
