# start with the node image
FROM alpine:latest as builder

#install nodejs into the base image
#use an older APK repo with openssl 1.0.2
RUN apk update && apk upgrade && \
    rm -f /var/cache/apk/*
RUN apk add nodejs && \
    rm -f /var/cache/apk/*
RUN apk add npm && \
    rm -f /var/cache/apk/*

ENV LANG C.UTF-8

# copy app's source files to the image
COPY src/package*.json ./
COPY src/index.js ./

# pull all required node packages into the app
RUN node -v

RUN npm cache clean --force
RUN npm install
RUN npm install natives@1.1.6

RUN rm -rf ./node_modules
RUN npm install --production

RUN npm dedupe

#copy again since npm install seems to overwrite this file
COPY src/index.js ./

FROM alpine:latest

LABEL maintainer="Predix Edge Application Services"
LABEL hub="https://hub.docker.com"
LABEL org="https://hub.docker.com/u/predixedge"
LABEL repo="predix-edge-sample-scaler-nodejs"
LABEL version="1.0.43"
LABEL support="https://forum.predix.io"
LABEL license="https://github.com/PredixDev/predix-docker-samples/blob/master/LICENSE.md"

RUN apk update && apk upgrade && \
    rm -f /var/cache/apk/*
RUN apk add nodejs && \
    rm -f /var/cache/apk/*

# Create app directory in the image
WORKDIR /usr/src/predix-edge-sample-scaler-nodejs

ENV LANG C.UTF-8

# copy app's source files to the image
COPY src/index.js ./
RUN mkdir -p node_modules
COPY --from=builder node_modules ./node_modules
# start the app
CMD [ "node", "index.js" ]
