FROM alpine:latest as extract

#TODO Remplacer par l'url de release github
ADD rudi-application-front-office-angular-dist.zip .
RUN unzip rudi-application-front-office-angular-dist.zip

FROM nginx:1.27.1-alpine

COPY rudi.conf /etc/nginx/conf.d/
COPY --from=extract ./angular-project/  /usr/share/nginx/html

