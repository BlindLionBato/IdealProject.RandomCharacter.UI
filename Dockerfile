FROM fedora:latest AS build

RUN dnf -y update && \
    dnf -y install nodejs git curl unzip

WORKDIR /
COPY package.json package-lock.json ./

RUN npm install

COPY . ./

RUN npm run build