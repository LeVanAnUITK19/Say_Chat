FROM node:20-alpine

WORKDIR /app

# Copy package files và install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY src/ ./src/

# Tạo thư mục uploads
RUN mkdir -p uploads

EXPOSE 5001

CMD ["node", "src/server.js"]
