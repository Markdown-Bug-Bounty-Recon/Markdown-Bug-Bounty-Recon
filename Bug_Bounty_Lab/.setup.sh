#!/bin/bash
export USER_ID=2000
export GROUP_ID=2000
find / -type f '(' -name '*.pacnew' -or -name '*.pacsave' ')' -delete 2> /dev/null
chmod 440 /etc/sudoers && \
groupadd --gid $GROUP_ID penelope && \
useradd --uid $USER_ID --gid $GROUP_ID --groups wheel --create-home penelope
rm -rf /etc/pacman.d/gnupg
export TERM=xterm && curl --silent --show-error https://blackarch.org/strap.sh | bash
cd /home/penelope || { echo "Failure in cd command"; exit 1; }


pacman --needed --noconfirm -Syu curl \
		wget \
		git \
		go \
		python \
		python-pip \
		iputils \
		ruby \
		zsh \
		gcc \
		openvpn \
		tmux \
		man-pages \
		man-db \
		lolcat \
		figlet \
    chsh \
    chpasswd \
		nodejs \
		base-devel \
		yarn \
		vim \
		vi \
		npm \
		postgresql \
		ruby-bundler \
		zsh-syntax-highlighting


#Setting up password for penelope
su root << EOF
echo "penelope:penelope" | chpasswd
EOF



# Setting up zsh and getting Luke Smith's .zshrc and installing oh-my-zsh

sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)" && \
rm ~/.zshrc && \
wget https://raw.githubusercontent.com/Cloufish/non_blackarch_tools/main/.zshrc -O ~/.zshrc && \
echo 'penelope' > chsh -s /usr/bin/zsh
### ASCII HEADER

wget https://raw.githubusercontent.com/Cloufish/non_blackarch_tools/main/.welcome.sh -O ~/.welcome.sh


# DOING THE SAME FOR ROOT USER
su root << EOF
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" && \
rm ~/.zshrc && \
wget https://raw.githubusercontent.com/Cloufish/voidrice/master/.config/zsh/.zshrc -O ~/.zshrc && \
chsh -s /usr/bin/zsh
EOF
# Setting up tmux


mkdir ~/.config/ && \
cd ~/.config/ ||  { echo "Failure in cd command"; exit 1; } && \
git clone https://github.com/gpakosz/.tmux.git && \
echo "set -g default-command /usr/sbin/zsh" >>  ~/.config/.tmux/.tmux.conf.local && \
ln -s -f ~/.config/.tmux/.tmux.conf ~/.tmux.conf && \
cp ~/.config/.tmux/.tmux.conf.local ~/.tmux.conf.local


wget https://raw.githubusercontent.com/LukeSmithxyz/voidrice/master/.config/nvim/init.vim && \
mkdir -p ~/.config/nvim && \
mv init.vim ~/.config/nvim && \
cp ~/.config/nvim/init.vim ~/ &&\
mv init.vim .vimrc && \



export MANPAGER="sh -c 'col -bx | bat -l man -p'" # Setting up man and bat

mkdir /home/penelope/PATH && \

mkdir -p /home/penelope/.gem/ruby/2.7.0/bin && \
mkdir -p /home/penelope/.local/bin

su root << EOF
pacman -Syyu --noconfirm
EOF
