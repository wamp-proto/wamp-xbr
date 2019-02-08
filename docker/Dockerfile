FROM node:latest

RUN mkdir /code
WORKDIR /code

RUN npm install -g truffle

ENTRYPOINT ["truffle"]
CMD ["compile", "--all"]
