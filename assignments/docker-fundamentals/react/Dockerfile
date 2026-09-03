FROM oven/bun:latest

WORKDIR /app

COPY ./package.json ./package.json
COPY ./bun.lock ./bun.lock

RUN bun install

COPY . .

EXPOSE 5173

CMD ["bun" , "run" , "dev"]