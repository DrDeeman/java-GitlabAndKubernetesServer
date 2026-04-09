# --- Этап 1: Сборка (Builder) ---
FROM eclipse-temurin:21-jdk-alpine AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# 1. Форсируем использование IPv4 (решает проблему зависаний в Docker-сетях)
ENV GRADLE_OPTS="-Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Addresses=true"


# Копируем только файлы сборки для кеширования зависимостей
COPY gradlew .
COPY gradle gradle
COPY build.gradle settings.gradle ./

# Даем права на выполнение (важно для Linux/GitLab)
RUN chmod +x gradlew

# 3. Хак для MTU прямо внутри контейнера (если есть права)
# И пробуем скачать зависимости. --no-daemon критичен для Docker
RUN ./gradlew dependencies --no-daemon || (ip link set dev eth0 mtu 1400 && ./gradlew dependencies --no-daemon)


# Копируем исходный код
COPY src src

# Собираем проект (пропускаем тесты для скорости, если они есть в отдельном шаге CI)
RUN ./gradlew bootJar -x test --no-daemon

# --- Этап 2: Финальный образ (Runtime) ---
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Копируем только собранный jar-файл из этапа сборки
COPY --from=builder /app/build/libs/*.jar app.jar

# Создаем пользователя для безопасности (не запускаем от root)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Прокидываем порт (обычно 8080)
EXPOSE 8080

# Запуск приложения
ENTRYPOINT ["java", "-jar", "app.jar"]