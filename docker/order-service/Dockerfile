# Étape 1 : Build
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY . .
RUN go mod init order-service
RUN go build -o order-service

# Étape 2 : Image finale légère
FROM alpine:latest

WORKDIR /app
COPY --from=builder /app/order-service .

EXPOSE 8003

CMD ["./order-service"]
