FROM fedora:latest AS build

RUN dnf -y update && \
    dnf -y install nodejs git curl unzip

WORKDIR /
COPY package.json package-lock.json ./

RUN npm install

COPY . ./

RUN npm run build

FROM fedora:latest AS runtime

RUN dnf -y install nginx

RUN mkdir -p /usr/share/nginx/html

COPY --from=build /dist /usr/share/nginx/html
COPY --from=build /configs/nginx.conf.template /etc/nginx/conf.d/nginx.conf.template
COPY --from=build /scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["nginx", "-g", "daemon off;"]