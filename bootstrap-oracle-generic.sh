#!/bin/bash
# --------------------------------------
#
#     Title: Chef Solo Bootstrap
#    Author: Terry Wang
#     Email: i (at) terry (dot) im
#  Homepage: http://terry.im
#      File: bootstrap-oracle-generic.sh
#   Created: June, 2013
#
#   Purpose: Bootstrap Ruby & Chef for Oracle Linux{5,6}
#
# --------------------------------------
# Exit immediately if any untested command fails
set -e
########### Setup Variables #############
RUBY_VERSION="ruby-1.9.3-p545"
RUBY_SOURCE="http://ftp.ruby-lang.org/pub/ruby/1.9/${RUBY_VERSION}.tar.gz"
LIBYAML_VERSION="yaml-0.1.5"
LIBYAML_SOURCE="http://pyyaml.org/download/libyaml/${LIBYAML_VERSION}.tar.gz"
PUBLIC_YUM_OL5="https://public-yum.oracle.com/public-yum-el5.repo"
PUBLIC_YUM_OL6="https://public-yum.oracle.com/public-yum-ol6.repo"
########### Setup Variables #############

# Fallback order /etc/oracle-release /etc/redhat-release
# /etc/enterprise-release /etc/system-release
# /etc/issue NO /etc/lsb-release file

# Determine release version
if [[ -f "/etc/oracle-release" ]]; then
    version=$(awk '{ print $5 }' /etc/oracle-release)
elif [[ -f "/etc/redhat-release" ]]; then
    version=$(awk '{ print $7 }' /etc/redhat-release)
elif [[ -f "/etc/enterprise-release" ]]; then
    version=$(awk '{ print $7 }' /etc/enterprise-release)
elif [[ -f "/etc/system-release" ]]; then
    version=$(awk '{ print $5 }' /etc/system-release)
elif [[ -f "/etc/issue" ]]; then
    version=$(grep Oracle /etc/issue | awk '{ print $5 }')
fi

# Determine major version
major_version=$(echo $version | cut -d. -f1)
case $major_version in
    "5") platform_version="5" ;;
    "6") platform_version="6" ;;
esac

echo "Release version => $version"
echo "Major version => $major_version"

# Configure Public YUM
if [[ $platform_version == "5" ]]; then
    if [[ -f "/etc/yum.repos.d/public-yum-el5.repo" ]]; then
        echo "Removing old public YUM configuration files..."
        rm -rf /etc/yum.repos.d/public-yum*.*
    fi
    echo "Downloading Public YUM configuration file for $version ..."
    wget -q $PUBLIC_YUM_OL5 -O /etc/yum.repos.d/public-yum-el5.repo
else
    if [[ -f "/etc/yum.repos.d/public-yum-ol6.repo" ]]; then
        echo "Removing old public YUM configuration files..."
        rm -rf /etc/yum.repos.d/public-yum*.*
    fi
    echo "Downloading Public YUM configuration file for ${version}..."
    wget -q $PUBLIC_YUM_OL6 -O /etc/yum.repos.d/public-yum-ol6.repo
fi

# Keep system up-to-date
yum update -y

echo "Install required packages to compile Ruby..."
# yum groupinstall 'Development Tools' -y
yum -y install gcc make gcc-c++ kernel-devel-`uname -r` \
    kernel-uek-devel-`uname -r` zlib-devel openssl-devel \
    readline-devel sqlite-devel perl wget dkms
# yum install libyaml libyaml-devel -y

echo "Removing any prior Ruby sources (if there is any)..."

if [[ -f "/tmp/${RUBY_VERSION}.tar.gz" ]]; then
    echo "Ruby source already exists, removing..."
    rm -f /tmp/${RUBY_VERSION}.tar.gz
fi

if [[ -f "/tmp/$RUBY_VERSION" ]]; then
    echo "Ruby source already exists, removing..."
    rm -rf /tmp/${RUBY_VERSION}
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
# Berkshelf requires libxml2-devel libxslt-devel

ret=$?
if [ $ret -ne 0 ]; then
    echo "Unfortunately something went wrong..." >&2
    exit 1
else
    echo "Ready to cook!"
fi

# Restart shell as login shell
exec $SHELL -l

exit 0
