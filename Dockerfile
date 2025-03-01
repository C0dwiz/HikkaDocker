# Dockerfile для Hikka (Оптимизированный, безопасный и надежный)

# Этап 1: Сборка (Builder)
FROM python:3.8-slim-buster AS builder

# Аргументы сборки
ARG APP_UID=1000
ARG APP_GID=1000

# Переменные окружения
ENV HIKKA_PIP_NO_CACHE_DIR=1 \
    HIKKA_PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Установка инструментов сборки
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    python3-dev \
    gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /root/.cache/pip/*

WORKDIR /app

# Клонирование репозитория с явным указанием версии
RUN git clone --depth 1 --branch main https://github.com/coddrago/Heroku.git .

# Создание и настройка виртуального окружения
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Обновление pip и установка зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Этап 2: Финальный образ
FROM python:3.8-slim-buster

# Аргументы и переменные окружения
ARG APP_UID=1000
ARG APP_GID=1000
ENV HIKKA_DOCKER=true \
    HIKKA_RATE=basic \
    HIKKA_PIP_NO_CACHE_DIR=1 \
    HOME=/home/appuser \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1

# Создание пользователя с ограниченными правами
RUN groupadd -g ${APP_GID} appuser && \
    useradd -u ${APP_UID} -g appuser -m appuser && \
    mkdir -p /app && \
    chown -R appuser:appuser /app

# Установка только необходимых runtime зависимостей
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    libcairo2 \
    libmagic1 \
    ffmpeg \
    neofetch \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Копирование артефактов из builder-образа
COPY --from=builder --chown=appuser:appuser /app /app
COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv

# Настройка рабочей директории и прав доступа
WORKDIR /app
RUN chmod -R 755 /app && \
    chmod -R 755 /opt/venv

# Переключение на непривилегированного пользователя
USER appuser

# Создание безопасного скрипта запуска
RUN echo '#!/bin/sh\nset -e\nsource /opt/venv/bin/activate\nexec python -m hikka' > /app/start.sh && \
    chmod 500 /app/start.sh

# Проверка целостности установки
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Запуск приложения
CMD ["/app/start.sh"]