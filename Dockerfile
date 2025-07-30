# Use the official Nginx base image
FROM nginx:alpine

# Set working directory (optional)
WORKDIR /usr/share/nginx/html

# Remove default Nginx static assets
RUN rm -rf ./*

# Copy static site files
COPY . .

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Expose custom port
EXPOSE 8088

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
