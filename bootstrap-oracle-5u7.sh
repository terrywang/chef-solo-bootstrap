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
#   Purpose: Bootstrap Ruby & Chef for OL 5.7
#
# --------------------------------------
########### Setup Ruby LibYAML Versions #############
RUBY_VERSION="ruby-1.9.3-p448"
RUBY_SOURCE="http://ftp.ruby-lang.org/pub/ruby/1.9/$RUBY_VERSION.tar.gz"
LIBYAML_VERSION="yaml-0.1.4"
LIBYAML_SOURCE="http://pyyaml.org/download/libyaml/${LIBYAML_VERSION}.tar.gz"
########### Setup Ruby LibYAML Versions #############

# Set proxy if behind firewall
# export http_proxy=""
# export https_proxy=""
# export ftp_proxy=""

# Manually create the ol5_u7_base repo file
# Here document
# Single quote or escape LimitString to disable substitution
cat <<'EOF' > /etc/yum.repos.d/el5u7.repo 
[ol5_u7_base]
name=Oracle Linux $releasever Update 7 installation media copy ($basearch)
baseurl=http://public-yum.oracle.com/repo/OracleLinux/OL5/7/base/$basearch/
gpgkey=http://public-yum.oracle.com/RPM-GPG-KEY-oracle-el5
gpgcheck=1
enabled=1
EOF

# Keep system up-to-date
yum update -y

echo "Installing required packages to compile Ruby..."
# yum groupinstall 'Development Tools' -y

# Break down to packages
yum -y install gcc make gcc-c++ kernel-devel-`uname -r` openssl-devel \
    zlib-devel readline-devel sqlite-devel perl wget curl sudo dkms bzip2
# yum install libyaml libyaml-devel -y

echo "Removing any prior Ruby sources (if there is any)..."

if [ -f "/tmp/$RUBY_VERSION.tar.gz" ]; then
    echo "Ruby source already exists, removing..."
    rm -rf "/tmp/$RUBY_VERSION.tar.gz"
fi

if [ -f "/tmp/$RUBY_VERSION" ]; then
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

echo "Downloading Ruby source..."
cd /tmp
wget $RUBY_SOURCE
tar zxf ${RUBY_VERSION}.tar.gz
cd $RUBY_VERSION

echo "Configuring and installing Ruby..."
./configure
make && make install

# zlib support may already be enabled, do again just in case
echo "Configure zlib support to Ruby..."
cd /tmp/${RUBY_VERSION}/ext/zlib
ruby extconf.rb
make && make install

# Skip to avoid issue CHEF-3933
# echo "Updating rubygems"
# gem update --system

echo "Installing chef client..."
gem install --no-ri --no-rdoc chef

echo "Installing bundler..."
gem install --no-ri --no-rdoc bundler ruby-shadow mcollective-client

ret=$?
if [ $ret -eq 0 ]; then
    echo "Ready to cook!"
else
    echo "Unfortunately something went wrong..." >&2
fi
exit $ret