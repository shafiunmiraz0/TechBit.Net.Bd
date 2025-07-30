# Use the official Nginx base image
FROM nginx:alpine

# Set working directory (optional, Nginx doesn't use this)
WORKDIR /usr/share/nginx/html

# Remove default Nginx static assets
RUN rm -rf ./*

# Copy all your local static files (HTML, CSS, JS, images, etc.)
COPY . .

# Expose HTTP port
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
