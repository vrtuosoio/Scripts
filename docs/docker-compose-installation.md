
## docker-compose Deployment Guide

### Prerequisites

* Linux (Ubuntu or any docker and docker-compose compatible distro)
* docker
* docker-compose
* redis (tested up to redis 4.x, covered by this installation guide and docker-compose template but can be updated to use externally available set up)
* mysql 8 (covered by this installation guide and docker-compose template but can be updated to use externally available set up)
* S3 (S3 or S3 compatible storage is required and for detail, please check the S3 configuration section)
* SMTP (required for email sending and 2 Factor Authentication)

Notes:

* All external loadbalancer/ingress are required to use TLS1.2 if SSL mode is enabled

#### Hardware Requirements
We recommend running the platform on a clean instance with the following specs

* 16GB RAM
* 4CPU
* 256GB Storage
* port 80 and 443 must be available

### 1. Download and Install Docker and docker-compose (required)

You must install docker and docker-compose and docker releases publicly available [here](https://docs.docker.com/engine/install/ubuntu/) for `docker` and [here](https://docs.docker.com/compose/install/) for `docker-compose`

### 2. Configure docker-compose.yml

Clone this repo

```
git clone https://github.com/vrtuosoio/Scripts.git
cd Scripts
```

Update `docker-compose.yml` available [here](https://github.com/vrtuosoio/Scripts/blob/master/docker/docker-compose.yml) with the appropriate configs

or open it directly in Terminal 

```
vi docker/docker-compose.yml
```

### 3. MySQL setup (optional)

#### Update DB Password
`docker-compose.yml` comes with `mysql`, the password defaults to `vrtuoso`, feel free to update the value if you want to choose another password. When updating the MySQL password, please make sure to update all `DB_PASSWORD` references in other services within the `docker-compose.yml` file. 

Optionally, you can remove the `mysql` block if you are running an external MySQL server, in this case, you need to update all of the following values in each of the `services`. If you do use an external `mysql`, please make sure to remove `- mysql` in the `links` block for every service.

```
DB_NAME: vrtuoso
DB_USERNAME: vrtuoso
DB_PORT: 3306
DB_PASSWORD: vrtuoso
DB_HOST: mysql
DB_SSL: disable
```

### 4. Redis setup (optional)
#### Update Redis Password
`docker-compose.yml` comes with redis, the password defaults to `vrtuoso`, feel free to update the value if you want to choose another password. When updating the Redis password, please make sure to update `REDIS_PASSWORD` environment variable in `redis` services within the `docker-compose.yml` file and also update the `REDIS_URL` in `socket-server-service` with the updated `REDIS_URL`, 

`REDIS_URL` uses the following format

```
redis://v:password@redis:6379
```

Optionally, you can remove the `redis` block if you are running an external Redis server, in this case, you need to update all of the following `REDIS_URL` value in `socket-server-service` with the your external `REDIS_URL`. If you do use an external `redis`, please make sure to remove `- redis` in the `links` block for every service.

### 5. S3 setup (required)

We use S3 for file object storage, any S3 API compatible services will be compatible with our API. Our API also proxies all operations with the S3 API. If you use an S3 compatible service such as AWS S3, DigitalOcean Space, Minio, Ceph, make sure to update the following values

```
S3_ENDPOINT: https://nyc3.digitaloceanspaces.com
S3_ACCESS_KEY_ID: s3_key_id
S3_SECRET_ACCESS_KEY: s3_secret_access_key
S3_REGION: nyc3
```

### 6. SMTP setup (required)

We use a generic SMTP setup, please make sure to update the following in `every` service within the `docker-compose.yml` file

```
SMTP_HOST: smtp.mailgun.org
SMTP_PORT: 587
SMTP_USERNAME: postmaster@mg.vrtuoso.io
SMTP_PASSWORD: smtppassword
```

To use custom `sent from` email for all notification emails, update the following environment variable in every service

```
FROM_EMAIL: "support+onprem@vrtuoso.io"
```

### 7. Request docker pull secret from VRtuoso Support (required)

Your docker registry secret to download compiled docker container images will come in the follow format

```
VRT_DOCKER_USER=vrtuoso+company123pull
VRT_DOCKER_PASSWORD=company123password
```

### 8. Run Deployment Script 

The docker registry credentials will authenticate with our registry for access to our compiled docker images. `export VRT_VERSION=${IMAGE_VER}` allows you to specify what version of the vrtuoso platform you want to run. All of our services are tagged by first 9 characters of `COMMIT HASH` such as `942cfc545`

To deploy
```
chmod 755 docker-compose-deploy.sh
VRT_DOCKER_USER=$DOCKER_USER VRT_DOCKER_PASSWORD=$DOCKER_PASSWORD VRT_VERSION=$VERSION ./docker-compose-deploy.sh
```
For example:
```
chmod 755 docker-compose-deploy.sh
VRT_DOCKER_USER=vrtuoso+company123pull VRT_DOCKER_PASSWORD=company123password VRT_VERSION=942cfc545 ./docker-compose-deploy.sh
```

### 9. Visit Deployed VRtuoso
Your VRtuoso instance comes default with no ssl configuration. Go to:

```
yourip:80
```

### 10. Update VRtuso Platform using `Simple Update`

Assuming you are updating to a version that is compatible with your current version of VRtuoso Platform, you can repeat `Step 7-10` using a new `VRT_VERSION`.

Note: Certain major updates with major Database schema changes will potentially be incompatible with older versions. Please consult with VRtuoso Support for confirmation on whether your current version supports `Simple Update` method.


### Configure SSL (optional)

If you use our nginx-proxy in `docker/nginx-proxy`. You can configure nginx to use SSL. Assuming you are inside the the root directory of this repo

```
cd docker/nginx-proxy
```

Update `ssl/ssl.key` with your SSL key and `ssl/ssl.pem` with your pem key (most pem key contains both the certificate and chained certificate). For more information on how https works within nginx, refer to the official nginx doc [here](http://nginx.org/en/docs/http/configuring_https_servers.html)

```
cp path/to/my/ssl.key ssl/ssl.key
cp path/to/my/ssl.pem ssl/ssl.pem
```

Now, update your `docker-compose.yml` file and change the `Dockerfile` reference for `nginx-proxy` to `Dockerfile.ssl` so the `nginx-proxy` block looks like the following

```
services:
  nginx-proxy:
    build:
      context:  ./nginx-proxy
      dockerfile: Dockerfile.ssl
```

You will then need to configure your DNS to point your domain associated with your SSL certificate to the ip of the machine you are running VRtuoso on.

Notes: 
* You will likely get a SSL cert verify error if you access via the IP but that would mean the certificate is being used.
* If you use a self-signed SSL cert, you might also receie a cert verify error

Visit:

```
https://yourdomain.com
```
