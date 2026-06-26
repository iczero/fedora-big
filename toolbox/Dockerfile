FROM localhost/fedora-big:44

RUN dnf do -y --action=install zsh tmux git fzf neovim tree-sitter-cli xxd ncurses-term jq \
  gcc g++ make cmake ninja-build python3 python3-pip \
  --action=upgrade '*'
RUN useradd devuser --shell /usr/bin/zsh && \
  usermod -a -G wheel devuser && \
  echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-nopasswd

USER devuser
RUN mkdir -p /home/devuser/.config && \
  cd /home/devuser/.config && \
  git clone https://github.com/iczero/dotfiles && \
  rm /home/devuser/.zshrc && \
  dotfiles/setup.sh

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | TMPDIR=/home/devuser sh

COPY --chown=devuser:devuser zshrc.local.default /home/devuser/.zshrc.local
COPY --chown=devuser:devuser zshenv.default /home/devuser/.zshen

# need root to start systemd
USER root

RUN ldconfig

COPY setup.sh /opt/container
COPY entrypoint-user-shell.conf /etc/systemd/system/container-entrypoint.service.d/
