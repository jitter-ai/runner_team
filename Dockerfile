# GitHub Actions self-hosted runner – minimal, Ubuntu 24.04 host compatible
FROM ghcr.io/myoung34/docker-github-actions-runner:latest

# Update paramiko to fix CryptographyDeprecationWarning
RUN pip install --upgrade paramiko

# Fix permissions for non-root user (UID 1000, GID 143)
RUN mkdir -p /actions-runner/_diag /_work/runner-1 /_work/runner-2 /_work/runner-3 && \
    chown -R 1000:143 /actions-runner /_work && \
    chmod -R u+rw /actions-runner /_work && \
    touch /actions-runner/.env /actions-runner/.path && \
    chown 1000:143 /actions-runner/.env /actions-runner/.path && \
    chmod u+rw /actions-runner/.env /actions-runner/.path

# Copy custom entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run as non-root user
USER 1000

ENTRYPOINT ["/entrypoint.sh"]