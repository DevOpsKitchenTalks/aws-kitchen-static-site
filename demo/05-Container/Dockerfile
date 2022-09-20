FROM node:18.9.0-alpine3.16 as build
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY scripts scripts
COPY src src
RUN npm run build

FROM nginx:1.23.1
ENV DKT_HOME=/opt/dkt/html
ENV NGINX_PORT=8080 NGINX_HOST=localhost
RUN mkdir -p ${DKT_HOME}
COPY demo/05-Container/nginx.conf.template /etc/nginx/templates/
COPY --from=build /usr/src/app/dist ${DKT_HOME}

EXPOSE ${NGINX_PORT}
