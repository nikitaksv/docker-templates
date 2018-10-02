ARG NGINX_TAG_VERSION=${NGINX_TAG_VERSION}
FROM nginx:${NGINX_TAG_VERSION}

COPY ./config/conf.d/ /etc/nginx/conf.d/
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh \
    && chown -R 1000:1000 /var/log/

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["nginx", "-g", "daemon off;"]
