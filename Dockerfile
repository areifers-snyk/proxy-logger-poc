# Single-container: OpenResty + Fluent Bit (build-from-source using pip-installed CMake)
FROM openresty/openresty:1.27.1.2-bullseye

# Install build deps + pip so we can get a modern CMake
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      curl \
      ca-certificates \
      python3 \
      python3-pip \
      libssl-dev \
      libyaml-dev \
      pkg-config \
      flex \
      bison \
      && rm -rf /var/lib/apt/lists/*

# Install a modern CMake via pip (this provides a cmake binary usable by cmake build)
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org cmake==3.24.2

# Download Fluent Bit source (v4.2.0) and extract
RUN mkdir -p /tmp/build && \
    curl -k -L https://github.com/fluent/fluent-bit/archive/refs/tags/v4.2.0.tar.gz \
      | tar xz -C /tmp/build

# Build Fluent Bit and install into /fluent-bit
RUN mkdir -p /tmp/build/fluent-bit-4.2.0/build && \
    cd /tmp/build/fluent-bit-4.2.0/build && \
    /usr/local/bin/cmake .. -DCMAKE_INSTALL_PREFIX=/fluent-bit && \
    make -j$(nproc) && \
    make install

# Create config dir and copy configs
RUN mkdir -p /fluent-bit/etc
COPY fluent-bit/fluent-bit.conf /fluent-bit/etc/fluent-bit.conf
COPY fluent-bit/parsers.conf /fluent-bit/etc/parsers.conf

# Create Nginx log directory and proxy.log file
RUN mkdir -p /var/log/nginx && \
    touch /var/log/nginx/proxy.log && \
    chmod 666 /var/log/nginx/proxy.log

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Copy OpenResty config
COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

ENV PORT=8080 
EXPOSE ${PORT}

# Start fluent-bit (from /fluent-bit/bin) and openresty
CMD ["/bin/sh", "/start.sh"]