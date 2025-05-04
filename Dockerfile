FROM python:3.10-slim

# Sistem bağımlılıkları (Playwright için)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libnss3 libatk-bridge2.0-0 libx11-xcb1 libdrm2 libxcomposite1 \
      libxrandr2 libgbm1 libasound2 libpangocairo-1.0-0 libgtk-3-0 \
      libglib2.0-0 libxshmfence1 libwayland-client0 libwayland-egl1 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python paketlerini yükle
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Playwright tarayıcılarını ekle
RUN playwright install --with-deps

# Uygulama kodunu kopyala
COPY . .

# Port ayarı ve server başlatma
ENV PORT=5000
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000"]
