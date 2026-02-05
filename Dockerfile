# Use Nginx as the base image
FROM nginx:alpine

# Copy your static website files to the Nginx html directory
# Is repository mein files root level par hain
COPY . /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
