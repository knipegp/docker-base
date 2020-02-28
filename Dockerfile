FROM ubuntu:18.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends git=1:2.17.1-1ubuntu0.5 \
    && apt-get install -y --no-install-recommends less=487-0.1 \
    # Curl
    && apt-get install -y --no-install-recommends curl=7.58.0-2ubuntu3.8 \
    && apt-get install -y --no-install-recommends ca-certificates=20180409 \
    # Neovim
    && apt-get install -y --no-install-recommends neovim=0.2.2-3 \
    && apt-get install -y --no-install-recommends python-neovim=0.2.0-1 \
    && apt-get install -y --no-install-recommends python3-neovim=0.2.0-1 \
    && apt-get install -y --no-install-recommends xsel=1.2.0-4 \
    && apt-get install -y --no-install-recommends xxd=2:8.0.1453-1ubuntu1.1 \
    # for YouCompleteMe
    && apt-get install -y --no-install-recommends build-essential=12.4ubuntu1 \
    && apt-get install -y --no-install-recommends cmake=3.10.2-1ubuntu2.18.04.1 \
    && apt-get install -y --no-install-recommends python3-dev=3.6.7-1~18.04 \
    && rm -rf /var/lib/apt/lists/* 

RUN curl -LO \
    https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb && \
    dpkg -i ripgrep_11.0.2_amd64.deb && \
    rm ripgrep_11.0.2_amd64.deb

RUN curl -LO \
    https://github.com/sharkdp/bat/releases/download/v0.12.1/bat_0.12.1_amd64.deb && \
    dpkg -i bat_0.12.1_amd64.deb && \
    rm bat_0.12.1_amd64.deb

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
