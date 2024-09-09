FROM ubuntu:latest

# Set the working directory inside the container
WORKDIR /app

RUN apt-get update && \
    apt-get install -y wget build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz && \
    tar -xf zig-linux-x86_64-0.13.0.tar.xz && \
    mv zig-linux-x86_64-0.13.0 /usr/local/zig && \
    ln -s /usr/local/zig/zig /usr/local/bin/zig

COPY . /app

RUN zig build 

RUN chmod +x ./zig-out/bin/zlog

EXPOSE 3000

CMD ["./zig-out/bin/zlog"]
