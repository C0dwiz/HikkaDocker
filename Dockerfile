# Dockerfile для Hikka (Оптимизированный, надежный, и готовый для Docker Hub)
# *** БЕЗ AppArmor ***

# Этап 1: Сборка (Builder) - Создаем артефакты для runtime-образа
FROM python:3.8-slim-buster AS builder

# Аргументы сборки (Настройка UID/GID для пользователя appuser)
ARG APP_UID=1000
ARG APP_GID=1000

# Переменные окружения (Управление pip и Python)
ENV HIKKA_PIP_NO_CACHE_DIR=1 \
    HIKKA_PYTHONUNBUFFERED=1

# Обновление и установка инструментов сборки (ОДИН слой для кэширования)
RUN apt-get update && \
    apt-get install -y --no-install-recommends git python3-dev gcc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Создание рабочей директории
WORKDIR /app

# Клонирование репозитория (shallow clone для уменьшения размера образа)
RUN git clone --depth 1 https://github.com/coddrago/Heroku.git .

# Создание виртуального окружения
RUN python -m venv /opt/venv

# Обновление pip
RUN /opt/venv/bin/pip install --upgrade pip

# Копирование файла зависимостей (кэширование Docker)
COPY requirements.txt .

# Установка зависимостей в виртуальное окружение
RUN /opt/venv/bin/pip install --no-warn-script-location --no-cache-dir -r requirements.txt

# Этап 2: Финальный образ (Runtime) - Запускаем приложение
FROM python:3.8-slim-buster

# Аргументы сборки (Настройка UID/GID для пользователя appuser)
ARG APP_UID=1000
ARG APP_GID=1000

# Создание пользователя и группы
RUN groupadd -g ${APP_GID} appuser && \
    useradd -u ${APP_UID} -g appuser -m appuser

# Переменные окружения (Настройка окружения Hikka)
ENV HIKKA_DOCKER=true \
    HIKKA_RATE=basic \
    HIKKA_PIP_NO_CACHE_DIR=1 \
    HOME=/home/appuser

# Установка зависимостей runtime (ОДИН слой, включая ca-certificates)
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl libcairo2 libmagic1 ffmpeg neofetch ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Очистка (Удаление ненужных инструментов) (ОДИН слой)
RUN apt-get update && apt-get install -y --no-install-recommends netcat netcat-traditional tcpdump nmap telnet openssh-client && \
    apt-get purge -y netcat netcat-traditional tcpdump nmap telnet openssh-client && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Копирование артефактов из builder-образа (Виртуальное окружение и код приложения)
COPY --from=builder --chown=appuser:appuser /app /app
COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv

# Назначение рабочей директории
WORKDIR /app

# Смена пользователя (Запуск приложения от имени пользователя appuser)
USER appuser

# Создание скрипта запуска (Активация виртуального окружения и запуск приложения)
RUN echo -e '#!/bin/bash\n source /opt/venv/bin/activate\n exec python -m hikka' > /app/start.sh && \
    chmod +x /app/start.sh

# Запуск приложения (Запускаем скрипт)
CMD ["/app/start.sh"]