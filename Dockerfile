# Use an official Node runtime as a parent image
FROM node:20-alpine

# Install PM2 globally
RUN npm install pm2 -g

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package*.json ./

# Install dependencies (production only)
RUN npm ci --only=production

# Copy the rest of the application code
COPY . .

# Ensure the uploads directory exists
RUN mkdir -p /app/uploads

# Expose port
EXPOSE 5000

# Start the application using PM2
CMD ["pm2-runtime", "ecosystem.config.js", "--env", "production"]
