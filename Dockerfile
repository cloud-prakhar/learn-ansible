FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1) Install SSH server, Python 3 and sudo
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server python3 sudo \
    && rm -rf /var/lib/apt/lists/*

# 2) Create the user Ansible will log in as
#    username: ansible   password: ansible123
#    The password is only used ONCE to copy our SSH key (ssh-copy-id).
RUN useradd -m -s /bin/bash ansible \
    && echo 'ansible:ansible123' | chpasswd \
    && echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible \
    && chmod 0440 /etc/sudoers.d/ansible

# 3) Prepare the SSH server
#    - /run/sshd must exist for sshd to start
#    - allow password login (needed for the first ssh-copy-id)
#    - generate host keys
RUN mkdir -p /run/sshd \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A

# 22 = SSH (Ansible), 80 = HTTP (nginx demo)
EXPOSE 22 80

# Run the SSH server in the foreground so the container keeps running
CMD ["/usr/sbin/sshd", "-D", "-e"]