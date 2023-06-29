############################
# STEP 1 build executable binary
############################
FROM golang:1.20 AS builder

# Install dependencies
WORKDIR /app
COPY . .

# Fetch dependencies.
# Using go get.
RUN go mod download

COPY . .

RUN go build -o main main.go

# Build the binary.
#RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go/main .

############################
# STEP 2 build a small image
############################
FROM alpine:latest
RUN apk --no-cache add ca-certificates libc6-compat

WORKDIR /

# Copy our static executable.
COPY --from=builder /app/main . 

ENV PORT 8080
ENV GIN_MODE release
EXPOSE 8080

# Run the Go Gin binary.
ENTRYPOINT ["./main"]
