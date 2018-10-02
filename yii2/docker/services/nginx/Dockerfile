ARG NGINX_TAG_VERSION=${NGINX_TAG_VERSION}
FROM nginx:${NGINX_TAG_VERSION}

ARG DOMAIN=${DOMAIN}
COPY ./config/conf.d/ /etc/nginx/conf.d/
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh \
    && chown -R www-data:www-data /var/log/

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]
