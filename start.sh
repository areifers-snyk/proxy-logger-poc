#!/bin/sh
# Replace the port placeholder in nginx.conf with the actual $PORT
sed -i "s/__PORT__/${PORT}/g" /usr/local/openresty/nginx/conf/nginx.conf

# Start Fluent Bit and OpenResty
/fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.conf &
openresty -g 'daemon off;'