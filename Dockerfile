# Simple Dockerfile for testing dangling images
FROM alpine:latest
RUN echo "This is a test image"
CMD ["echo", "Hello from test image"] 