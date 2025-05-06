# Dockerfile

# Playwright + Python resmi imajı, gerekli glibc ve tarayıcılarla beraber
FROM mcr.microsoft.com/playwright-python:1.52

WORKDIR /app

# Önce bağımlılıkları yükleyelim
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama kodunu kopyala
COPY . .

# Port ayarı
ENV PORT=5000

# Web süreci için Gunicorn, Worker için Procfile'daki komutu kullanacağız
# Railway Docker runtime, Procfile içindeki worker sürecini de ayağa kaldırır
CMD ["bash", "-lc", "honcho start -f Procfile"]
