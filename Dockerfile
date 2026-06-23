FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json .npmrc ./
RUN npm install

FROM base AS tester
COPY . .
RUN npm test

FROM node:20-alpine AS client-builder
WORKDIR /client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build

FROM base AS development
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

FROM node:20-alpine AS final
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm install --only=production
COPY backend/ ./backend
COPY --from=client-builder /client/dist ./client/dist
COPY --from=tester /app/package.json /app/package.json
EXPOSE 3000
CMD ["node", "backend/src/index.js"]