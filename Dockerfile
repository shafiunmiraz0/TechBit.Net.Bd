# Use the official Nginx base image
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default Nginx static assets
RUN rm -rf ./*

# Copy all static assets
COPY . .
COPY assets/ ./assets/
COPY images/ ./images/

# Copy all HTML files
COPY *.html ./

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose the port defined in nginx.conf
EXPOSE 8088

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
