# Single-container: OpenResty + Fluent Bit (build-from-source)
FROM openresty/openresty:1.27.1.2-bullseye

# Install build deps + pip (for modern CMake)
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

# Install modern CMake via pip
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

# Create Fluent Bit config directory
RUN mkdir -p /fluent-bit/etc

# Copy Fluent Bit configs
COPY fluent-bit/fluent-bit.conf /fluent-bit/etc/fluent-bit.conf
COPY fluent-bit/parsers.conf /fluent-bit/etc/parsers.conf

# Create NGINX/OpenResty log path
RUN mkdir -p /var/log/nginx && \
    touch /var/log/nginx/proxy.log && \
    chmod 666 /var/log/nginx/proxy.log

# Copy NGINX/OpenResty config
COPY nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Expose internal port
EXPOSE 8080

# Start Fluent Bit and OpenResty
CMD ["/bin/sh","-c","/fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.conf & openresty -g 'daemon off;'"]