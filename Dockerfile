FROM node:alpine

RUN apk --no-cache add bash curl jq make

COPY package.json /package.json
COPY yarn.lock    /yarn.lock

RUN yarn install --production

COPY . /

ENTRYPOINT ["make"]
