# マルチステージビルド: 開発 + 本番

# ==========================================
# ステージ 1: バックエンド ビルド
# ==========================================
FROM node:18-alpine AS server-build

WORKDIR /app/server

COPY server/package*.json ./

RUN npm ci --production

COPY server/ .

# ==========================================
# ステージ 2: フロントエンド ビルド
# ==========================================
FROM node:18-alpine AS client-build

WORKDIR /app/client

COPY client/package*.json ./

RUN npm ci

COPY client/ .

RUN npm run build

# ==========================================
# ステージ 3: 本番イメージ
# ==========================================
FROM node:18-alpine

WORKDIR /app

# バックエンド
COPY --from=server-build /app/server/node_modules ./server/node_modules
COPY --from=server-build /app/server ./server

# フロントエンド（静的ファイル）
RUN apk add --no-cache http-server
COPY --from=client-build /app/client/dist ./server/public

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:5000/health', (r) => {if (r.statusCode !== 200) throw new Error()})"

EXPOSE 5000

CMD ["node", "server/server.js"]
