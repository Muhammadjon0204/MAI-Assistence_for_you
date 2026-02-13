# Stage 1: Build the Flutter web app
FROM ubuntu:20.04 AS build

RUN apt-get update && \
    apt-get install -y bash curl file git unzip xz-utils zip libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
ENV FLUTTER_CHANNEL="stable"
ENV FLUTTER_VERSION="3.29.0"
# Using a specific known version or latest stable
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor

WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build web
RUN flutter build web --release

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Copy the built web assets from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
