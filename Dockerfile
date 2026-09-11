FROM diegosouzapw/omniroute:3.8.50

USER root

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh \
 && mkdir -p /app/data \
 && (chown -R node:node /app/entrypoint.sh /app/data 2>/dev/null || true)

ENV PORT=8080
ENV HOSTNAME=0.0.0.0
ENV NODE_ENV=production
ENV AUTH_COOKIE_SECURE=true
ENV DATA_DIR=/app/data
ENV STORAGE_DRIVER=sqlite

USER node
EXPOSE 8080
CMD ["/app/entrypoint.sh"]
