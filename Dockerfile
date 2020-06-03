FROM ubuntu:18.04

WORKDIR /app

ENV LANG="C.UTF-8" \
    LANGUAGE="zh_CN.UTF-8" \
    RUST_LOG=info

ADD fs/ /

RUN apt-get update && apt-get install -y ca-certificates && apt-get clean  && rm -rf /var/lib/apt/lists/*

