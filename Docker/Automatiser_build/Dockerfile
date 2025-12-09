# Dockerfile léger pour test CI/CD
FROM alpine:3.18

# Installer curl et vim pour simuler des packages à mettre à jour
RUN apk update && apk add --no-cache curl \
    echo "Hello from lightweight Alpine Dockerfile" > /hello.txt

# Commande par défaut
CMD ["cat", "/hello.txt"]
