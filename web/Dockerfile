# web: nginx sirviendo la página y reenviando /api/ al backend.
# Imagen "unprivileged": corre como usuario nginx (uid 101) y escucha en 8080.
# 1.30 es la rama estable de nginx; la 1.29 dejó de actualizarse (mayo de 2026) y arrastraba 47 HIGH de Alpine 3.23.
FROM nginxinc/nginx-unprivileged:1.30-alpine3.24

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY public/ /usr/share/nginx/html/

EXPOSE 8080
