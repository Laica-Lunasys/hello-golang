FROM golang:1.12.6 AS build
WORKDIR /go/src/github.com/Laica-Lunasys/hello-golang

ENV GOOS linux
ENV CGO_ENABLED 0

RUN go get -u -v github.com/golang/dep/cmd/dep

ADD Gopkg.lock Gopkg.lock
ADD Gopkg.toml Gopkg.toml
RUN dep ensure -v --vendor-only
COPY . .
RUN go build -a -installsuffix cgo -v -o hello-golang cmd/hello-golang/main.go

FROM alpine
WORKDIR /app

EXPOSE 8080
COPY --from=build /go/src/github.com/Laica-Lunasys/hello-golang/hello-golang /app/
COPY docker-entrypoint.sh /app/

RUN apk add --no-cache ca-certificates

ENTRYPOINT ["sh", "/app/docker-entrypoint.sh"]
