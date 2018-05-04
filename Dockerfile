FROM golang:1.8-alpine as builder

RUN apk add git --no-cache

RUN go get -u github.com/golang/dep/cmd/dep

ADD https://api.github.com/repos/gustavosbarreto/dkron-executor-http/git/refs/heads/master /tmp/
RUN go get -u github.com/gustavosbarreto/dkron-executor-http

WORKDIR /go/src/github.com/victorcoder

ADD https://api.github.com/repos/gustavosbarreto/dkron/git/refs/heads/master /tmp/
RUN git clone https://github.com/gustavosbarreto/dkron.git

WORKDIR /go/src/github.com/victorcoder/dkron

RUN dep ensure
RUN go install

FROM alpine:3.6

RUN apk add ca-certificates --no-cache

COPY --from=builder /go/bin/dkron /usr/bin/
COPY --from=builder \
     /go/bin/dkron-executor-http \
     /usr/bin/

EXPOSE 8080 8946

ENTRYPOINT ["/usr/bin/dkron"]
CMD ["--help"]
