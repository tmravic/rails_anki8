FROM ruby:4.0.4-slim

# USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose build --no-cache rspec
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=rails

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      postgresql-client \
      curl \
      libjemalloc2 \
      libvips42 \
      pkg-config \
      libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

# Create group + user with your exact host UID/GID
RUN groupadd -g ${GROUP_ID} ${USERNAME} && \
    useradd -u ${USER_ID} -g ${GROUP_ID} -m -s /bin/bash ${USERNAME}

WORKDIR /rails

# Pre-create bundle directory and give ownership
ENV BUNDLE_PATH=/usr/local/bundle
RUN mkdir -p $BUNDLE_PATH && chown -R ${USERNAME}:${USERNAME} /rails $BUNDLE_PATH

# === Install gems during build ===
USER ${USERNAME}
COPY --chown=${USERNAME}:${USERNAME} Gemfile* ./
RUN bundle install --jobs=4 --retry=3

# Copy the rest of the application
COPY --chown=${USERNAME}:${USERNAME} . .

# Default command
CMD ["bash"]
