FROM node:latest

RUN mkdir /code
WORKDIR /code

RUN npm install -g truffle

COPY ./run /

ENTRYPOINT ["/run"]
# CMD ["run"]
