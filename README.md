<div align="center">

# System-Wide Node Development Container

</div>

A persistent Docker container for Node.js development that runs continuously, providing faster access and better resource efficiency compared to per-project dev containers.

## Why use a container?

NPM packages can be malicious and have full access to your system during installation and execution. Running Node.js development in a container provides isolation and limits potential damage from compromised packages.

## Benefits

- **Faster**: always running – no container startup time compared to regular per-project dev containers.
- **Resource efficient**: single container – less disk space and memory overhead.
- **Space efficient**: project files, NVM Node versions, and `node_modules` are shared with the host.
- **Secure**: isolates npm packages from the host system.

## Setup

1. Start the container:

```bash
docker-compose up -d
```

2. Add this alias to your shell configuration (`~/.zshrc` or `~/.bashrc`):

```bash
alias d='docker exec -it -w "/workspace${PWD#$HOME/repositories}" docker-dev /bin/zsh'
```

(Replace `repositories` by the path in your home folder containing your projects.)

## Usage

From your host system, navigate to any project directory under `~/repositories` and run:

```bash
d
```

This drops you into the container at the corresponding `/workspace` path, ready to run Node.js commands:

```bash
npm install
npm run dev
node script.js
```

The most common ports for web applications are exposed (see the compose file). However, you might need to tweak your commands. For example, with a Vite project, run:

```bash
npm run dev -- --host 0.0.0.0
```

## How it works

- Your `~/repositories` directory is mounted to `/workspace` in the container.
- The alias calculates the relative path from `~/repositories` and sets the working directory accordingly.
- NVM is installed for Node version management.

## Container management

```bash
# View logs
docker-compose logs -f

# Restart container
docker-compose restart

# Stop container
docker-compose down

# Rebuild after Dockerfile changes
docker-compose up -d --build
```
