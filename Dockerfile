FROM ubuntu:22.04

ARG USERNAME

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    locales \
    curl \
    zsh \
    git \
    nano \
    trash-cli \
    build-essential \
    libssl-dev

# Delete package lists from `apt-get update`
RUN rm -rf /var/lib/apt/lists/*

# Set up locale to prevent issues with tab completion in Oh My Zsh; https://superuser.com/a/1780048/738113
RUN echo "en_AU.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG en_AU.UTF-8
ENV LANGUAGE en_AU:en
ENV LC_ALL en_AU.UTF-8

RUN useradd -m -s /bin/zsh ${USERNAME}
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# Create `~/.config` folder so USERNAME is the owner; if we don't, the volume
# `~/.config/git/ignore:/home/${USER}/.config/git/ignore` in the compose file
# will make Docker to create `~/.config` with `root` as its owner.
RUN mkdir /home/${USERNAME}/.config

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Copy zsh configuration
COPY --chown=${USERNAME}:${USERNAME} container-content/.zshrc /home/${USERNAME}/.zshrc
COPY --chown=${USERNAME}:${USERNAME} container-content/robbyrussell.zsh-theme /home/${USERNAME}/.oh-my-zsh/custom/themes/robbyrussell.zsh-theme

# Copy VS Code settings
COPY --chown=${USERNAME}:${USERNAME} container-content/vscode-settings.json /home/${USERNAME}/.vscode-server/data/Machine/settings.json

# Install NVM (node versions will be mounted from host)
ENV NVM_DIR=/home/${USERNAME}/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# Create local bin and add it to PATH
RUN mkdir -p /home/${USERNAME}/.local/bin
ENV PATH="/home/${USERNAME}/.local/bin:${PATH}"

# Install Sublime Merge command messenger
COPY --chown=${USERNAME}:${USERNAME} --chmod=755 container-content/host-exec-sublime-merge /home/${USERNAME}/.local/bin/host-exec-sublime-merge

WORKDIR /home/${USERNAME}/dev

CMD ["/bin/zsh"]
