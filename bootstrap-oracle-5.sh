#!/bin/bash
# --------------------------------------
#
#     Title: Chef Solo Bootstrap
#    Author: Terry Wang
#     Email: i (at) terry (dot) im
#  Homepage: http://terry.im
#      File: bootstrap-oracle57.sh
#   Created: 19 June, 2013
#
#   Purpose: Bootstrap Ruby & Chef for OL 5
#
# --------------------------------------
########### Setup Ruby LibYAML Versions #############
RUBY_VERSION="ruby-1.9.3-p448"
RUBY_SOURCE="http://ftp.ruby-lang.org/pub/ruby/1.9/${RUBY_VERSION}.tar.gz"
LIBYAML_VERSION="yaml-0.1.4"
LIBYAML_SOURCE="http://pyyaml.org/download/libyaml/${LIBYAML_VERSION}.tar.gz"
########### Setup Ruby LibYAML Versions #############

# Set proxy if behind firewall
# export http_proxy=""
# export https_proxy=""
# export ftp_proxy=""

# Use Oracle Public YUM Server
if [[ -f "/etc/yum.repos.d/public-yum-el5.repo" ]]; then
    echo "Removing old public yum configuration files..."
    rm -f /etc/yum.repos.d/public-yum*.*
fi

cd /etc/yum.repos.d
wget https://public-yum.oracle.com/public-yum-el5.repo

# Keep system up-to-date
yum update -y

echo "Installing required packages for compiling Ruby..."
# yum groupinstall 'Development Tools' -y

# Break down to packages
yum -y install gcc make gcc-c++ kernel-devel-`uname -r` openssl-devel \
    zlib-devel readline-devel sqlite-devel perl wget curl sudo dkms bzip2
# yum install libyaml libyaml-devel -y

echo "Removing any prior Ruby sources (if there is any)..."

if [[ -f "/tmp/${RUBY_VERSION}.tar.gz" ]]; then
    echo "Ruby source already exists, removing..."
    rm -f "/tmp/${RUBY_VERSION}.tar.gz"
fi

if [[ -f "/tmp/$RUBY_VERSION" ]]; then
    echo "Ruby source already exists, removing..."
    rm -rf "/tmp/$RUBY_VERSION"
fi

echo "Downloading and compiling LibYAML..."
# Compile libyaml from source
cd /tmp
wget $LIBYAML_SOURCE
tar zxf ${LIBYAML_VERSION}.tar.gz
cd $LIBYAML_VERSION
./configure
make && make install

echo "Downloading Ruby source tarball..."
cd /tmp
wget $RUBY_SOURCE
tar zxf ${RUBY_VERSION}.tar.gz
cd $RUBY_VERSION

echo "Configuring and installing Ruby..."
./configure
make && make install

# Skip to avoid issue CHEF-3933
# echo "Updating rubygems"
# gem update --system

echo "Installing chef client..."
gem install --no-ri --no-rdoc chef

echo "Installing bundler..."
gem install --no-ri --no-rdoc bundler
# Berkshelf requires libxml2-devel and libxslt-devel

ret=$?
if [ $ret -eq 0 ]; then
    echo "Ready to cook!"
else
    echo "Unfortunately something went wrong..." >&2
fi
exit $ret
