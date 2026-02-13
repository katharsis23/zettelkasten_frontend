
# We define the TARGET_OS here so we can use it in FROM instructions later!
ARG TARGET_OS=web
# Flutter version from .fvmrc
ARG FLUTTER_VERSION=3.35.6

# --- Stage 1: The Builder ---
FROM --platform=$BUILDPLATFORM growerp/flutter-sdk-image:${FLUTTER_VERSION} AS builder

ARG TARGET_OS
WORKDIR /app

COPY ./todo_app/pubspec.yaml ./todo_app/pubspec.lock ./
RUN flutter pub get

COPY ./todo_app/ .


USER root
RUN if [ "$TARGET_OS" = "linux" ]; then \
    apt-get update && apt-get install -y \
    clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev; \
    fi && \
    chown -R mobiledevops:mobiledevops /app && \
    git config --global --add safe.directory /home/mobiledevops/.flutter-sdk && \
    git config --global --add safe.directory /app

USER mobiledevops

RUN case "$TARGET_OS" in \
    "web") \
    flutter build web --release ;; \
    "android") \
    flutter config --enable-android && \
    flutter build apk --release ;; \
    "linux") \
    flutter build linux --release ;; \
    "windows") \
    flutter build windows --release ;; \
    "ios") \
    flutter config --enable-ios && \
    flutter build ios --release --no-codesign ;; \
    *) \
    echo "Unsupported platform: $TARGET_OS" && exit 1 ;; \
    esac

# --- Stage 2: Web Runtime (Lightweight Nginx) ---
FROM nginx:alpine AS web-runtime
COPY --from=builder /app/build/web /usr/share/nginx/html
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    location / { \
    root /usr/share/nginx/html; \
    index index.html index.htm; \
    try_files $uri $uri/ /index.html; \
    } \
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ { \
    expires 1y; \
    add_header Cache-Control "public, immutable"; \
    } \
    }' > /etc/nginx/conf.d/default.conf
EXPOSE 80
# Alpine use wget instead of curl for healthcheck! <3
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost/ || exit 1
CMD ["nginx", "-g", "daemon off;"]

# --- Stage 3: Linux Runtime ---
FROM ubuntu:22.04 AS linux-runtime
RUN apt-get update && apt-get install -y \
    libgtk-3-0 libxss1 libgconf-2-4 libasound2 \
    libatk1.0-0 libcups2 libdrm2 libxcomposite1 \
    libxdamage1 libxrandr2 libgbm1 libxkbcommon0 \
    libnss3 libxfixes3 libappindicator3-1 \
    libsecret-1-0 libstdc++6 libjsoncpp25 libcurl4 \
    curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/build/linux/x64/release/bundle /app/
ENV DISPLAY=:99
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep -f todo_app > /dev/null || exit 1
CMD ["/app/todo_app"]

# --- Stage 4: Android Build Output (Just for retrieval) ---
FROM alpine:latest AS android-runtime
RUN apk add --no-cache unzip curl
WORKDIR /output
COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk ./app-release.apk
RUN echo "# Flutter Android Build" > build-info.txt && \
    echo "APK Location: /output/app-release.apk" >> build-info.txt && \
    echo "Build Date: $(date)" >> build-info.txt && \
    echo "Size: $(du -h app-release.apk | cut -f1)" >> build-info.txt
EXPOSE 8080
CMD ["sh", "-c", "echo '=== Build Info ===' && cat build-info.txt && echo '=== Files ===' && ls -la && echo '=== APK Ready ===' && tail -f /dev/null"]

# --- Stage 5: iOS Build Output ---
FROM alpine:latest AS ios-runtime
RUN apk add --no-cache curl
WORKDIR /output
COPY --from=builder /app/build/ios/iphoneos/Runner.app ./Runner.app
RUN echo "# Flutter iOS Build" > build-info.txt && \
    echo "App Location: /output/Runner.app" >> build-info.txt && \
    echo "Build Date: $(date)" >> build-info.txt && \
    echo "Size: $(du -sh Runner.app | cut -f1)" >> build-info.txt && \
    echo "Note: This build needs to be codesigned for distribution" >> build-info.txt
EXPOSE 8080
CMD ["sh", "-c", "echo '=== Build Info ===' && cat build-info.txt && echo '=== Files ===' && ls -la && echo '=== iOS App Ready ===' && tail -f /dev/null"]

# --- Stage 6: Windows Build Output ---
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS windows-runtime
WORKDIR /app
COPY --from=builder /app/build/windows/x64/runner/Release /app/
RUN echo "# Flutter Windows Build" > build-info.txt && \
    echo "Executable Location: /app/todo_app.exe" >> build-info.txt && \
    echo "Build Date: $(date)" >> build-info.txt
CMD ["todo_app.exe"]

# --- Final Stage: The Choice! ---
# This part uses the ARG we defined at the very top!
FROM ${TARGET_OS}-runtime AS final
