# Stage 1: Build
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with verbose logging to debug issues
RUN npm install --verbose

# Copy source code for build
COPY . .

# Stage 2: Run
FROM node:18-alpine 

# Set working directory
WORKDIR /app

# Copy node_modules from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Command to run the app
CMD ["node", "index.js"]
