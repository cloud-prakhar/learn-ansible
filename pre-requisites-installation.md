# 01: Prerequisites and Installation

1. A Linux shell (Linux, macOS or WSL2 on Windows)
2. Ansible installed and working
3. Docker installed and working (to run lab servers)
---

## 1. What we need to know before starting

We do not need to be Linux experts, but these basics help:

| Skill | Why it matters | Example |
|-------|----------------|---------|
| Basic Linux commands | Ansible automates Linux tasks, so you should know what the task does manually | `ls`, `cd`, `cat`, `mkdir`, `sudo apt install` |
| SSH basics | Ansible connects to servers using SSH | `ssh user@server-ip` |
| A text editor | Playbooks and inventory are plain text files | VS Code, vim, nano |
| YAML basics (optional) | Playbooks are written in YAML; we cover it in block 07 | `key: value` |

## 2. Where do we install Ansible?

This is the most important point of the installation block:

> **Ansible is installed on ONE machine only: the _control node_.**
> The servers you manage (_managed nodes_) do **not** need Ansible installed. They only need **SSH** and **Python**.

```mermaid
flowchart LR
    subgraph CONTROL["Control Node (install Ansible HERE)"]
        C1["Linux / macOS / WSL2"]
        C2["Python 3"]
        C3["Ansible"]
    end
    subgraph MANAGED["Managed Nodes (NOTHING to install)"]
        M1["SSH server running"]
        M2["Python 3 present"]
        M3["A user with sudo"]
    end
    CONTROL == "SSH" ==> MANAGED

    style CONTROL fill:#bbdefb,stroke:#0d47a1,color:#000
    style MANAGED fill:#c8e6c9,stroke:#1b5e20,color:#000
```

### Control node requirements

| Requirement | Details |
|-------------|---------|
| Operating system | Linux (any distro), macOS, or **WSL2 on Windows** |
| Python | Python 3.10 or newer (the newest Ansible releases need 3.11+). pipx/apt handle this for you. |
| Not supported | **Native Windows cannot be a control node.** Windows users must use WSL2 (or a Linux VM). Windows *can* be a managed node. |

### Managed node requirements

| Requirement | Details |
|-------------|---------|
| SSH server | Running and reachable on port 22 (or a custom port) |
| Python 3 | Most Ansible modules are Python scripts that run on the managed node. Almost every Linux distro ships Python 3. |
| User account | A user Ansible can log in as, with `sudo` rights if it needs to install packages or edit system files |

## 3. Windows users: set up WSL2 first

Skip this if you use Linux or macOS.

Open **PowerShell as Administrator** and run:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart when asked, open "Ubuntu" from the Start menu, and create a Linux username and password. **Run every command in this course inside the Ubuntu (WSL) terminal**, not in PowerShell.

> **Important WSL tip:** keep course files inside the Linux filesystem (for example `~/learn-ansible`), **not** under `/mnt/c/...`.
> Windows folders appear world-writable inside WSL, and Ansible **ignores `ansible.cfg` in world-writable folders** for security reasons. Block 05 explains why.

## 4. Install Ansible

### `ansible` vs `ansible-core`

Two Python packages exist, and we often ask which one to install:

| Package | What you get | When to use |
|---------|--------------|-------------|
| `ansible-core` | The engine, the CLI tools (`ansible`, `ansible-playbook`, …) and the built-in modules (`ansible.builtin.*`) | Minimal installs and CI pipelines |
| `ansible` | `ansible-core` **plus** ~85 community collections (AWS, Docker, network devices, MySQL, …) | **Learning and day-to-day use (we use this)** |

### Option A: pipx (recommended, works on any Linux, WSL or macOS)

`pipx` installs Python applications in their own isolated environment, so Ansible cannot break the system Python (and system updates cannot break Ansible).

```bash
# Ubuntu / Debian / WSL
sudo apt update
sudo apt install -y pipx
pipx ensurepath          # adds ~/.local/bin to your PATH
# close and reopen the terminal

pipx install --include-deps ansible
```

On macOS: `brew install pipx && pipx ensurepath`, then `pipx install --include-deps ansible`.

> **Why not `sudo pip install ansible`?** On Ubuntu 23.04+ and Debian 12+, `pip install` into the system Python fails with `error: externally-managed-environment`. This is intentional (PEP 668), so use pipx or a virtual environment.

### Option B: Ubuntu package (apt with the official PPA)

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

### Option C: Python virtual environment (if you need a specific version)

```bash
python3 -m venv ~/ansible-venv
source ~/ansible-venv/bin/activate
pip install ansible
# run "source ~/ansible-venv/bin/activate" again in every new terminal
```

### Option D: other OS package managers

```bash
sudo dnf install -y ansible          # Fedora / RHEL 9 / Rocky / Alma
brew install ansible                 # macOS with Homebrew
```

### Verify the installation

```bash
ansible --version
```

Expected output (versions will differ):

```text
ansible [core 2.16.3]
  config file = None
  configured module search path = ['/home/user/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/user/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, ...) [GCC 13.2.0]
  jinja version = 3.1.2
  libyaml = True
```

### Tools that come with Ansible

Installing Ansible gives you several commands. In this session we use:

| Command | Purpose |
|---------|---------|
| `ansible` | Run a single **ad-hoc** task on servers |
| `ansible-playbook` | Run a **playbook** (a file with many tasks) |
| `ansible-inventory` | View and verify your inventory |
| `ansible-config` | View and verify configuration |
| `ansible-doc` | Offline documentation for every module |

## 5. Install Docker (to run lab servers)

We use Docker containers as lightweight "servers" for practice. Each container runs SSH and behaves like a small Ubuntu server.

| Platform | How to install |
|----------|----------------|
| Windows (WSL2) | Install **Docker Desktop** and enable *Settings → Resources → WSL Integration → Ubuntu* |
| macOS | Install **Docker Desktop** |
| Linux | Use the official convenience script below |

```bash
# Linux only
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
# log out and log back in (or run: newgrp docker)
```

Verify Docker:

```bash
docker --version
docker compose version
docker run --rm hello-world
```

## Checkpoint:

```bash
ansible --version
ansible-playbook --version
docker compose version
python3 --version
```

## Common installation problems

| Problem | Fix |
|---------|-----|
| `ansible: command not found` after pipx | Run `pipx ensurepath`, then close and reopen the terminal |
| `error: externally-managed-environment` | Don't use `sudo pip`. Use pipx (Option A) or a venv (Option C). |
| `permission denied ... /var/run/docker.sock` | `sudo usermod -aG docker $USER`, then log out and back in |
| Docker commands fail inside WSL | Start Docker Desktop on Windows and enable WSL integration for your distro |
| `ERROR: Ansible requires blocking IO on stdin/stdout/stderr` | Rare; happens in some IDE terminals. Run from a normal terminal. |