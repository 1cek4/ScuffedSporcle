FROM node:18

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY ./src ./src

EXPOSE 8083

CMD ["node", "src/app.js"]

ENV JWT_SECRET=4dc4704e8afa99a9f0e55710b54345867a6f3b5a464532095b618889a32e7c6e
ENV PORT=8083