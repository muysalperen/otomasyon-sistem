# Dockerfile

# Playwright için glibc uyumlu resmi Python imajı
FROM mcr.microsoft.com/playwright-python:v1.52.0

WORKDIR /app

# Python bağımlılıklarını yükle
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama kodunu kopyala
COPY . .
