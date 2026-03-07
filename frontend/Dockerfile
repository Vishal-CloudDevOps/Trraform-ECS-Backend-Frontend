# ---- Runtime Stage ----
# Lightweight nginx to serve the Angular static build
FROM nginx:1.25-alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy built Angular app (replace 'src/' with 'dist/<your-app-name>/' after running ng build)
COPY src/ /usr/share/nginx/html/

# Nginx config: SPA routing + gzip + security headers
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
