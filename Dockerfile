# Multi-Stage Dockerfile for React Application
# Stage 1: Build stage using Node.js
# Stage 2: Production stage using Nginx

# ============================================
# Stage 1: Builder
# ============================================
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the React application
RUN npm run build

# ============================================
# Stage 2: Production
# ============================================
FROM nginx:alpine

# Set working directory for nginx
WORKDIR /usr/share/nginx/html

# Copy built React app from builder stage
COPY --from=builder /app/build .

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
