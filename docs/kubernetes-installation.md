
## Kubernetes Deployment Guide

### Prerequisites

* Kubernetes (ver. 1.15+ tested and recommended)
* Redis (tested up to redis 4.x, covered by this installation guide and docker-compose template but can be updated to use externally available set up)
* MySQL 5.6 (covered by this installation guide and docker-compose template but can be updated to use externally available set up)
* S3 (S3 or S3 compatible storage is required and for detail, please check the S3 configuration section)
* SMTP (required for email sending and 2 Factor Authentication)

#### Tools for Deployment

On the deployment machine that has access to the kubernetes cluster, the following are required to deploy our kubernetes configurations onto the cluster

* kubectl (ver. 1.15+ tested or latest kubectl compatible with your kubernetes cluster, check [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for latest instructions)
* helm (ver. v2.14+ tested or latest helm version found [here](https://helm.sh/docs/intro/install/) 
* docker (optional, but if case you prefer to not install kubectl or helm onto your deployment machine, you can use our prepared docker-based installer for kubernetes)

#### Hardware Requirements
We recommend running the platform on a clean namespace of Kubernetes with the following specs

* 3-5 vm Kubernetes cluster recommended for availability and HA (High Availability)

Recommended Per VM Spec:

* 4GB RAM
* 2CPU
* 100GB Storage


### 1. Configure values.yml

We use helm chart to configure our kubernetes configurations. However, we do not rely on kubernetes helm installation to manage deployment. It is simply used as a templating tool to faciliate generation of kubernetes config yaml files. Clone this repo

```
git clone https://github.com/vrtuosoio/Scripts.git
cd Scripts/kubernetes
```

Copy the values file from helm chart into the your current `kubernetes` directory

```
cp charts/vrtuoso/values.yaml deploy-values.yaml
```

Update `deploy-values.yaml` that you just copied with your values. The template `values.yaml` file is available [here](https://github.com/vrtuosoio/Scripts/blob/master/kuberentes/charts/vrtuoso/values.yaml) for preview.


The following table lists the configurable parameters of the vrtuoso chart and their default values.

| Parameter                        | Description                                                 | Default           |
| -------------------------------  | ----------------------------------------------------------- | ----------------- |
| namespace                        | Kubernetes namespace you plan to deploy on             | vrtuoso           |
| image.tag                        | Tag version for docker images provided by vrtuoso           | release-v1        |
| listen.host                      | Listening on a specific network host                        | 0.0.0.0           |
| listen.port                      | Listening on a specific network port                        | 3000              |
| tls.enabled                      | Enable SSL to run over HTTPS                                | false             |
| tls.secretName                   | Name to set for the secret for SSL                               |             |
| tls.secretCrt                    | Base64 encoded string for your SSL Crt                              |             |
| tls.secretKey                    | Base64 encoded string for your SSL Key (pem key that includes your chain |                                                    | null              |
| ingress.provider                 | Your ingress provider type based on Cloud provider (rancher-v1|digitalocean|gke|eks)                                | digitalocean              |
| shared.env.HOST_URL             | The URL you will be accessing the vrtuoso platform including the scheme (http|https)                             |   https://portal.vrtuoso.io            |
| shared.env.JWT_SECRET_KEY        | Random generated key for JWT token encryption shared amongst all services   | secret |
| database.type                    | Backend database type                                       | h2                |
| database.encryptionKey           | Secret key for encrypt sensitive information into database  | null              |
| database.connectionURI           | Database connection URI (alternative to the below settings) | null              |
| mysql.host                       | Database host url                                              | null              |
| mysql.username                | Database username                                           | null              |
| mysql.password                | Database password                                           | null              |
| mysql.database                   | Database name                                               | null              |
| mysql.port                       | Database port                                               | 3306              |
| mysql.ssl                       | Database SSL setting                                               | disable              |
| socketserver.env.REDIS_URL     | When using an external redis (redis.incluster false), update this value to your REDIS_URL | |
| redis.incluster                       | Whether to install redis in cluster using our redis config  | false
| redis.env.REDIS_PASSWORD                | Redis password to set when installing redis incluster                                           | vrtuoso              |


### 3. MySQL setup (required)

#### Update DB Password
`deploy-values.yml` , your must update the following values to use your external MySQL connection string. Refer to the Configuration table reference in Step 1 for what each of field means.
```
mysql:
  host: mysqlhost
  username: vrtuoso
  password: vrtuoso
  database: vrtuoso
  port: 3306
  ssl: disable
```

### 4. Redis setup (optional)
#### Update Redis Password
Our chart comes with redis. The password defaults to `vrtuoso`, feel free to update the value if you want to choose another password. You must enable it by setting `redis.incluster: true`

For example:
```
redis:
  image: {}
  incluster: false
  env:
    REDIS_PASSWORD: vrtuoso
```
Feel free to also update the `REDIS_PASSWORD` to anything you prefer, this is for internal access by the socketserver and never exposed to the public

Optionally, you can remove the `redis` block if you are running an external Redis server, in this case, you need to update `REDIS_URL` value in `socketserver.env` with the your external `REDIS_URL` and set `redis.incluster: false`

`REDIS_URL` uses the following format

```
redis://v:password@redis:6379
```

### 5. S3 setup (required)

We use S3 for file object storage, any S3 API compatible services will be compatible with our API. Our API also proxies all operations with the S3 API. If you use an S3 compatible service such as AWS S3, DigitalOcean Space, Minio, Ceph, make sure to update the following values

Update the following values under `api.env`
```
S3_ACCESS_KEY_ID: s3accesskeyid
S3_SECRET_ACCESS_KEY: s3secret
S3_BUCKET: s3bucket
S3_ENDPOINT: https://s3.us-east-1.amazonaws.com
S3_REGION: us-east-1
```

### 6. SMTP setup (required)

We use a generic SMTP setup, please make sure to update the following values in `deploy-values.yaml` created in Step 1.

Update the following values under `api.env`
```
SMTP_HOST: smtp.mailgun.org
SMTP_PORT: 587
SMTP_USERNAME: postmaster@mg.vrtuoso.io
SMTP_PASSWORD: smtppassword
```
### 7. Request Kubernetes Docker Registry pull secret from VRtuoso Support (required)

Your docker registry secret to download compiled docker container images will come in the follow format

Update `registry.dockerConfigJson` in `deploy-values.yaml`

For example:

```
registry:
  dockerConfigJson: ewogICJhdXRocyI6IHsKICAgICJxdWF5LmlvIjogewogICAgICAiYXV0aCI6ICJkbkowZFc5emJ5dGtaWEJzYjNrNk1qTkdPVXhGVVRVelVsbFlSVFJXV2xWRVRsSlRURFpZUXpWQk9FWldRVnBOVlRkRE4wa3dNMEU1VUU5UlF6
```

### 8. Run Deployment Script 

```
```

### 9. Visit Deployed VRtuoso
Your VRtuoso instance comes default with no ssl configuration. Go to:

```
yourip:80
```