#!/bin/sh
export BASE_PATH="${BASE_PATH:-/}"
sed "s|{{BASE_PATH}}|${BASE_PATH}|g" /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/nginx.conf
exec nginx -g 'daemon off;'
