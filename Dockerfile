# syntax=docker/dockerfile:1
FROM node:20-alpine AS base
WORKDIR /app

# Install dependencies first for better layer caching
COPY package*.json ./
RUN npm ci --omit=dev

# Copy the rest of the application
COPY . .

ENV NODE_ENV=production \
    PORT=8000 \
    HOST=0.0.0.0

EXPOSE 8000
CMD ["node", "server.js"]
