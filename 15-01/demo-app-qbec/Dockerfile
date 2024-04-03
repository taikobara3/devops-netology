FROM nginx:latest
RUN rm -rf /usr/share/nginx/html/*
RUN mkdir -p /usr/share/nginx/html/
COPY --chown=nginx index.html /usr/share/nginx/html/
COPY --chown=nginx ./images/fox.png /usr/share/nginx/html/images/
COPY --chown=nginx favicon.ico /usr/share/nginx/html/
