# start with the node image
FROM node:10-alpine

LABEL maintainer="Predix Edge Adoption"
LABEL hub="https://hub.docker.com"
LABEL org="https://hub.docker.com/u/predixadoption"
LABEL repo="predix-edge-sample-scaler-nodejs"
LABEL version="1.0.29"
LABEL support="https://forum.predix.io"
LABEL license="https://github.com/PredixDev/predix-docker-samples/blob/master/LICENSE.md"

ENV LANG C.UTF-8

# Create app directory in the image
WORKDIR /usr/src

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

RUN rm -rf ./bower_components
RUN rm -rf ./cache
RUN rm -rf /root/.npm
RUN rm -rf /root/.cache
RUN rm -rf /root/.gnupg
RUN rm -rf ./gulp_tasks
RUN rm -rf ./server
RUN rm -rf ./src
RUN rm -rf ./images

#copy again since npm install seems to overwrite this file
COPY src/index.js ./

# start the app
CMD [ "node", "index.js" ]
