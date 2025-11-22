# Nginx + Fluent Bit Sidecar POC

> **⚠️ Proof of Concept Only**  
> This project is **not** intended for production use.  
> SSL/TLS **certificate validation is disabled** due to Zscaler-controlled development environments that intercept HTTPS traffic.

---

## Overview

This repository contains a **single-container POC** combining:

- **OpenResty (Nginx + Lua)** as a reverse proxy that captures:
  - HTTP request bodies
  - HTTP response bodies
  - Metadata (headers, IPs, methods, status codes)

- **Fluent Bit v4.2.0** built from source and configured to:
  - Tail JSON logs from `/var/log/nginx/proxy.log`
  - Forward them to your desired output (e.g., Loggly)

The purpose of this POC is to demonstrate a **sidecar-style logging solution** even within **restricted network environments** such as those behind Zscaler.

---

## Features

- Single Docker container running both OpenResty and Fluent Bit  
- Request/response logging via Lua hooks (`access_by_lua` / `body_filter_by_lua`)  
- JSON log output formatted for Fluent Bit ingestion  
- Fluent Bit built from source for compatibility behind SSL-intercepting proxy  
- Auto-created log directory and file:
  - `/var/log/nginx/proxy.log`
  - `chmod 666` for read/write access  
- Certificate checks explicitly bypassed during build steps

---

## Prerequisites

- Docker Engine installed
- `.env` file (optional) for environment variables such as Loggly token:

```env
LOGGLY_TOKEN=your-loggly-token
```

## Building the Image

```bash
docker build -t nginx-fluentbit-poc .
```

## Running the Container

```bash
docker run --env-file .env -p 8080:8080 nginx-fluentbit-poc
```

After launching:
	•	OpenResty (Nginx) listens on port 8080
	•	Fluent Bit tails the logs from /var/log/nginx/proxy.log
	•	Fluent Bit forwards the logs to Loggly

## Known Limitations

⚠️ This is strictly a proof-of-concept.

	•	SSL verification is disabled using:
	•	curl -k
	•	pip --trusted-host bypasses
	•	Not hardened for production security
	•	Fluent Bit is built from source because package repos are inaccessible behind Zscaler
	•	No guarantee of performance or reliability at production scale
	•	Logs stored in a world-writable file (POC convenience)

## Useful References
	•	Fluent Bit Documentation: https://docs.fluentbit.io/manual/
	•	OpenResty Documentation: https://openresty.org/en/
	•	Lua CJSON Library: https://www.kyne.com.au/~mark/software/lua-cjson.php