# LARAVEL-TEMPLATE

### Infrastructure

* Nginx
* MariaDB
* PHP-FPM 7.2 (LARAVEL)
* Memcached
* Redis

### Installation

* Run the command in the root directory project: 

```
    cd docker && cp .env.sample .env && docker-compose up --build -d
```

### Default settings

* Domain name   - laravel.loc
* Debug         - enabled
* DataBase:
  * Name 	- laravel
  * User 	- root
  * Password 	- defender

#### Default IP address docker containers

* Nginx                 - 172.29.0.21
* MariaDB               - 172.29.0.22
* PHP-FPM 7.2 (LARAVEL) - 172.29.0.23
* Memcached             - auto
* Redis                 - auto