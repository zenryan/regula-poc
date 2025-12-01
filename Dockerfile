# Use the official Regula Forensics DocReader image as base
FROM regulaforensics/docreader:latest

# Set working directory
WORKDIR /app

# Copy configuration and license files
COPY config.yaml /app/config.yaml
COPY regula.license /app/extBin/unix/regula.license

# Expose the application port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=60s --start-period=60s --timeout=30s --retries=5 \
  CMD curl -f http://127.0.0.1:8080/api/ping || exit 1
