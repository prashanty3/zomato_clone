# Stage 1: Build
FROM node:20 as builder

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Stage 2: Serve
FROM node:20

RUN npm install -g serve
WORKDIR /app
COPY --from=builder /app/dist ./dist
CMD ["serve", "-s", "dist"]
