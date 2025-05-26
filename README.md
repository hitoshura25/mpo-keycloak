# mpo-keycloak
Keycloak Optimized image for MPO


## Building docker image
### Install Docker
https://www.docker.com/get-started/

### Create a buildx builder (if not already created)
`docker buildx create --use --name mybuilder`

### Build the image
`docker buildx build -t mpo-keycloak:latest --load .`