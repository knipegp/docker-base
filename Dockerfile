FROM ubuntu:latest

RUN apt update
RUN apt upgrade -y
RUN apt install -y curl
RUN apt install -y neovim
RUN apt install -y git
# Dependencies for YouCompleteMe
RUN apt install -y build-essential cmake python3-dev

RUN curl -LO \
    https://github.com/BurntSushi/ripgrep/releases/download/11.0.2/ripgrep_11.0.2_amd64.deb && \
    dpkg -i ripgrep_11.0.2_amd64.deb && \
    rm ripgrep_11.0.2_amd64.deb

# Thanks for the help Nico
ARG USER_ID
ARG GROUP_ID
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

USER root
WORKDIR /root
