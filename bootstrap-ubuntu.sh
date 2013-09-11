#!/bin/bash
# --------------------------------------
#
#     Title: Chef Solo Bootstrap
#    Author: Terry Wang
#     Email: i (at) terry (dot) im
#  Homepage: http://terry.im
#      File: bootstrap-ubuntu.sh
#   Created: Feb, 2013
#
#   Purpose: Bootstrap Ruby and Chef on Ubuntu
#
# --------------------------------------
########### Setup Variables #############
RUBY_VERSION="1.9.3-p448"
########### Setup Variables #############

# Keep system up-to-date
sudo apt-get -y update

# Install dependencies
sudo apt-get -y install git build-essential libssl-dev zlib1g-dev \
libreadline6-dev libyaml-dev

# Check if rbenv is already installed
if [ -d ~/.rbenv ]; then
    echo "rbenv already installed, remove ~/.rbenv if you want to bootstrap."
    exit 1
fi

# Install rbenv and ruby-build
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

# Set up PATH
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
# Enable shims and autocompletion
echo 'eval "$(rbenv init -)"' >> ~/.profile

# ~/.profile will NOT be read if ~/.bash_profile presents
if [ -f ~/.bash_profile ] || [ -h ~/.bash_profile ]; then
    echo "~/.bash_profile found, backing up to ~/.bash_profile.old"
    mv ~/.bash_profile{,.old}
fi

# ~/.profile will NOT be read if ~/.bash_login presents
if [ -f ~/.bash_login ] || [ -h ~/.bash_login ]; then
    echo "~/.bash_login found, backing up to ~/.bash_login.old"
    mv ~/.bash_login{,.old}
fi

# Reload ~/.profile for Ubuntu
source ~/.profile

# Install ruby from source via ruby-build
rbenv install $RUBY_VERSION -v

# Set system wide
rbenv global $RUBY_VERSION

# Skip to avoid issue CHEF-3933
# echo "Updating rubygems..."
# gem update --system

# Install gems
# rbenv-rehash replaces rbenv rehash
gem install --no-ri --no-rdoc rbenv-rehash bundler chef
# Berkshelf requires libxml2-dev libxslt1-dev

ret=$?
if [ $ret -ne 0 ]; then
    echo "Unfortunately something went wrong..." >&2
else
    echo "Ready to cook!"
fi

# Restart shell as login shell
exec $SHELL -l

exit 0