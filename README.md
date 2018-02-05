
## What is included?
This Dockerfile will install Nginx and php-fpm7. MySQL is not included in this. You need a remote mysql server for this to work.

### How to use it
Clone this repo to wherever you will be hosting your Docker container
```
git clone https://github.com/denisgolius/docker-wp-nginx-php7
cd docker-wp-nginx-php7
```
Edit the `start.sh` file and fill in 
```
  WORDPRESS_DB="your_db_name"
  WORDPRESS_HOST="your_db_mysql_host"
  WORDPRESS_USER="your_db_username"
  WORDPRESS_PASSWORD="your_db_username_password"
```
save the file and exit

Build your image
```
docker build -t "denisgolius/docker-wp-nginx-php7" .
```
Once the build is complete, you can start a container with it.
This will map your host machines port 80 to the container's port 80 and you will be able to access the
site in your host machine at `localhost` 
```
sudo docker run -it -p 80:80 denisgolius/docker-wp-nginx-php7
```
If you want the container to run in the background, you can use
```
docker run -it -p 80:80 --name wp-nginx -d denisgolius/docker-wp-nginx-php7
```
If you are using a Linux distro, you may need to use the above command with `sudo` inorder to bind to local port 80

`docker ps` should show the container and you can access it with
```
 docker exec -it container_id_here bash
```

### HELPP!!??
If you have any questions, or need any help with it, leave a issue for this repository.


NOTES:
This is heavily adapted from [HERE](https://github.com/eugeneware/docker-wordpress-nginx). Checkout his repository to see how you can use it with a local MySQL. 
# docker-wp-nginx-php7

PS: Forked from https://github.com/MansoorMajeed/docker-wp-nginx-php7
