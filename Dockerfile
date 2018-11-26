# start with the node image
FROM node

LABEL maintainer="Predix Builder Relations"
LABEL hub="https://hub.docker.com"
LABEL org="https://hub.docker.com/u/predixadoption"
LABEL version="1.0.18"
LABEL support="https://forum.predix.io"
LABEL license="https://github.com/PredixDev/predix-docker-samples/blob/master/LICENSE.md"

ENV LANG C.UTF-8

#install nodejs into the base image
#RUN apk update && apk add nodejs


# Create app directory in the image
WORKDIR /usr/src

# copy app's source files to the image
COPY src/package*.json ./
COPY src/index.js ./

# pull all required node packages into the app
RUN npm install

# start the app
CMD [ "node", "index.js" ]
