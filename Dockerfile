# Use lightweight Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /usr/src/app

# Copy public assets only (no Node app backend assumed)
COPY public ./public/

# Install static file server globally
RUN npm install -g serve

# Use non-root user for security
RUN addgroup -g 1001 -S nodejs \
 && adduser -S nextjs -u 1001 \
 && chown -R nextjs:nodejs /usr/src/app

USER nextjs

# Expose port
EXPOSE 8080

# Health check for load balancer
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
 CMD wget --quiet --spider http://localhost:8080 || exit 1

# Run static file server
CMD ["serve", "public", "-l", "8080", "-s"]