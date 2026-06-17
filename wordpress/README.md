# WordPress on containers

This is my attempt to create a local wordpress development environment based on containers.

## Inspiration

I was inspired by this YouTube video for the most part: https://www.youtube.com/watch?v=kIqWxjDj4IU

## Requirements

- docker/podman
- docker compose/podman-compose
- mkcert

## Included

- Nginx
- PHP
- MySQL
- WordPress
- WP-CLI
- Local SSL certificates with `mkcert`

## Usage

1. Clone this repository.
2. Download the latest WordPress zip file from https://wordpress.org/download/ and unzip it in the `wordpress` folder.
3. Rename `wordpress/wp-config-sample.php` to `wordpress/wp-config.php`.
4. Update the `compose.yml` file and `wordpress/wp-config.php` file with your own settings (database name, user, password, etc).
5. Run `mkcert -install` to install the mkcert authority in your system.
6. Run `cp "$(mkcert -CAROOT)/rootCA.pem" .` to copy mkcert ca cert into current directory.
7. Run `mkcert wp.local` to create a certificate for the domain `wp.local`.
8. Put the certificate files in the `nginx/certs` folder.
9. After that you can run `docker compose up -d --build` to start the containers and `docker compose down` to stop them.
10. You can now access your WordPress site at `https://wp.local`.
11. You can also access the wp-cli directly using a command like `docker compose run --rm wp user list`.

> [!WARNING]
> Rootless container engines like Podman, can't bind port 80 or 443 by default, as these are previlledged ports.
> Easiest solution, is to run `sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80` every time before starting the containers.
> Maybe network aliases are broken there though.

> [!TIP]
> Everywhere you see `wp.local` you can replace it with your own local domain. Just make sure you update the `server_name`
> , the `ssl_certificate` and the `ssl_certificate_key` in the `nginx/default.conf` file accordingly. Also, the `etc/hosts` file (or the equivalent on your OS)
> needs to be updated with your local domain.

## License

This project is released into the public domain. See the [LICENSE](../LICENSE) file for more information.
