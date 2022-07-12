FROM alpine:latest

# Install tftp-hpa
RUN apk add --no-cache tftp-hpa busybox

# Configure tftp-hpa
RUN adduser -D tftp
COPY mapfile /etc/tftp/mapfile



# Copy Start Script
COPY start /usr/sbin/start
ENTRYPOINT ["/usr/sbin/start"]
