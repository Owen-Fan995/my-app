# Build stage
FROM node:22-alpine AS build

WORKDIR /app

# Use a faster npm mirror for dependency installation
RUN npm config set registry https://registry.npmmirror.com

# Copy package.json files first to leverage Docker cache
COPY package*.json ./
RUN npm ci --omit=dev

# Copy the project files and build the application
COPY . .  
RUN npm run build

# Runtime stage
FROM node:22-alpine AS runtime

WORKDIR /app

# Copy only necessary files from the build stage to reduce image size
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./
COPY --from=build /app/.next ./.next
COPY --from=build /app/public ./public

EXPOSE 3000

# Run as a non-root user for security
USER node

CMD ["npm", "start"]


