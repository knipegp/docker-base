FROM ubuntu:19.10

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    less \
    # Curl
    curl \
    ca-certificates \
    # Neovim
    neovim \
    python-neovim \
    python3-neovim \
    xsel \
    xxd \
    # for YouCompleteMe
    build-essential \
    cmake \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -LO \
    https://github.com/BurntSushi/ripgrep/releases/download/12.0.1/ripgrep_12.0.1_amd64.deb && \
    dpkg -i ripgrep_12.0.1_amd64.deb && \
    rm ripgrep_12.0.1_amd64.deb

RUN curl -LO \
    https://github.com/sharkdp/bat/releases/download/v0.13.0/bat_0.13.0_amd64.deb && \
    dpkg -i bat_0.13.0_amd64.deb && \
    rm bat_0.13.0_amd64.deb

# Thanks for the help Nico
ARG USER_ID
ARG GROUP_ID
# TODO: move user adding functionality to docker run instead of build to allow
#       other users on the system to use this container.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN useradd -m --uid $USER_ID developer && \
    echo "developer:devpasswd" | chpasswd && \
    usermod -aG dialout developer && \
    usermod -aG sudo developer

USER developer
WORKDIR /home/developer
RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
RUN git clone https://github.com/knipegp/dotfiles.git

RUN mkdir -p ./.config/nvim

RUN ln -s /home/developer/dotfiles/dotfiles/vimrc /home/developer/.config/nvim/init.vim
RUN cp /home/developer/dotfiles/dotfiles/bashrc /home/developer/.bashrc

RUN nvim +PlugInstall +qall

# Install YouCompleteMe
# Add flags to end of command for particular language support
RUN python3 ./.config/nvim/plugged/YouCompleteMe/install.py
