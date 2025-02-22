# Hikka Docker Image: Безопасный и Оптимизированный образ

Этот репозиторий предоставляет Dockerfile для создания Docker-образа Hikka, вашего мощного инструмента для Telegram. Образ спроектирован для удобного развертывания в Docker Hub и обеспечения надежной, оптимизированной среды выполнения Hikka.

**Вы можете выбрать один из двух вариантов:**

*   **Использовать готовый образ:** Просто и быстро разверните предварительно собранный, протестированный образ Hikka из Docker Hub. (Ссылка на Docker Hub будет здесь, когда вы его опубликуете). Это самый простой способ начать работу.
*   **Собрать свой собственный образ:** Если вам нужны дополнительные настройки, хотите контролировать процесс сборки или использовать последние изменения, вы можете собрать Docker-образ Hikka самостоятельно, используя предоставленный Dockerfile.

## 💎 Ключевые Особенности

*   **🚀 Оптимизированный Размер:** Благодаря многоступенчатой сборке (multi-stage build), финальный образ имеет минимальный размер, что экономит ресурсы и ускоряет развертывание.  Первый этап собирает необходимые компоненты (зависимости, код), а второй этап переносит только необходимое в runtime-образ.
*   **🛡️ Повышенная Безопасность:** Hikka запускается от имени непривилегированного пользователя `appuser`, снижая риски, связанные с запуском процессов от имени root.  **Внимание!**  В этой конфигурации **НЕ** используется AppArmor. Мы настоятельно рекомендуем рассмотреть возможность использования AppArmor или других механизмов контроля доступа для дополнительной изоляции.
*   **🛠️ Гибкая Настройка:** Настройте UID/GID пользователя `appuser` во время сборки образа, чтобы соответствовать требованиям вашей инфраструктуры.
*   **⚡️ Эффективное Кэширование:** Интеллектуальная структура Dockerfile позволяет эффективно использовать кэш Docker, значительно ускоряя последующие сборки.
*   **📦 Готов к Работе "Из Коробки":**  Содержит скрипт `start.sh`, который автоматически активирует виртуальное окружение и запускает Hikka, упрощая процесс развертывания.
*   **🩺 Инструменты Диагностики (временно):**  Содержит полезные утилиты, такие как `curl`, `libcairo2`, `libmagic1`, `ffmpeg`, `neofetch` для базовой функциональности и `netcat`, `tcpdump`, `nmap`, `telnet`, `openssh-client` для диагностики и отладки (удаляются после установки, чтобы минимизировать размер образа).

## 🗂️ Содержимое Репозитория

*   `Dockerfile`: Инструкции для сборки Docker-образа Hikka.
*   `requirements.txt`: Список Python-зависимостей, необходимых для работы Hikka.
*   `apparmor-profile`: (УДАЛЕНО в этой версии, создайте свой) Файл профиля AppArmor для ограничения возможностей контейнера.  **ВНИМАНИЕ: Эта версия Dockerfile не использует AppArmor.**

## 🚀 Использование

### 1. Установите Готовый Образ (Рекомендуется для начинающих)

```bash
docker pull codwiz/hikka
docker run -d codwiz/hikka
```
