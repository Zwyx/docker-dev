FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    zsh \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*
# Create a non-root user with zsh as default shell
RUN useradd -m -s /bin/zsh user

# Switch to the non-root user
USER user
WORKDIR /home/user

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Copy zsh configuration
COPY --chown=user:user .zshrc /home/user/.zshrc
COPY --chown=user:user robbyrussell.zsh-theme /home/user/.oh-my-zsh/custom/themes/robbyrussell.zsh-theme

# Add local bin to PATH
ENV PATH="/home/user/.local/bin:${PATH}"

# Install NVM (node versions will be mounted from host)
ENV NVM_DIR=/home/user/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# Set working directory for projects
WORKDIR /workspace

# Default command
CMD ["/bin/zsh"]
