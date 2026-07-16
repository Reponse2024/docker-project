FROM node:20-alpine AS client-builder
WORKDIR /client
COPY client/package*.json ./

COPY .npmrc* ./ 
RUN npm install
COPY client/ ./
RUN npm run build

FROM node:20-alpine AS final
WORKDIR /app

COPY backend/package*.json ./
COPY .npmrc* ./
RUN npm install --omit=dev

COPY backend/ ./

COPY --from=client-builder /client/dist ./src/static

EXPOSE 3000
ENV NODE_ENV=production

CMD ["node", "src/index.js"]