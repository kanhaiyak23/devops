# Stage 1: Build the React frontend
FROM node:20-alpine AS build-client
WORKDIR /app/client
COPY client/package*.json ./
RUN npm install
COPY client/ ./
RUN npm run build -- --base=/

# Stage 2: Build the Node.js backend
FROM node:20-alpine
WORKDIR /app/server
COPY server/package*.json ./
RUN npm install --production
COPY server/ ./

# Copy built frontend from Stage 1 into the correct path expected by Express
COPY --from=build-client /app/client/dist /app/client/dist

# Expose the correct environment port
EXPOSE 5001

# Healthcheck — verifies the app is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD wget -qO- http://localhost:5001/api/health || exit 1

# Drop to non-root user for runtime (security best practice)
USER node

# Start the application
CMD ["node", "src/index.js"]