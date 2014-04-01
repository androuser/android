#!/bin/bash
#
# This script will initialize an android build environment
# for use with the AOSP, Cyanogenmod Project, Ubuntu Touch
#
# Script has been tested with lubuntu 12.10 and 13.04
# Should be functional on any debian based Linux
#
#

SH=$(readlink /bin/sh)
BASH=$( which bash )
STUDIO_BUILD="130.687321"
ANDROID_STUDIO_BUNDLE_FILENAME="android-studio-bundle-$STUDIO_BUILD-linux.tgz"
ANDROID_STUDIO_BUNDLE_PATH="/var/cache/$ANDROID_STUDIO_BUNDLE_FILENAME"
# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
        exit
}

function print_status(){
        
        echo "init_android_dev:$1"
        
        
        
        
}

if [ "$SH" != "$BASH" ] ; then

        
        print_status "Updating shell symlink to bash"
        sudo rm /bin/sh
        sudo ln -s $BASH /bin/sh
fi
echo -e "Android Developement Environment Initialization Script\nFor Debian Based Linux Distributions"

if [ "$1" != "noapt" ] ; then

# Ubuntu archive repositories which contain the sun-java-jdk's
# NOTE: The Official AOSP setup documentation is incorrect 
# All three repositories are required, regardless of whether you want
# to install the java5-jdk or not

# Remove the repos first, this should avoid a buildup of the same repo
# should the script be run multiple times


echo -e "Installing Packages\nAdding Required Repositories"
           
sudo add-apt-repository --remove --yes "deb http://archive.canonical.com/ lucid partner"
sudo add-apt-repository --remove --yes "deb http://archive.ubuntu.com/ubuntu hardy main multiverse"
sudo add-apt-repository --remove --yes "deb http://archive.ubuntu.com/ubuntu hardy-updates main multiverse"

sudo add-apt-repository "deb http://archive.canonical.com/ lucid partner"
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu hardy main multiverse"
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu hardy-updates main multiverse"
echo "Ubuntu archive respositories added for official sun java jdk version 5 & 6"

# webupd8 ppa repositories for new / alternative java apt repositories
sudo add-apt-repository --remove --yes ppa:webupd8team/java
sudo add-apt-repository --yes ppa:webupd8team/java
echo "Webupd8 respository added for official oracle java jdk version 6, 7 & 8"

# Ubuntu Touch Developer Preview Tools PPA 
sudo add-apt-repository --remove --yes ppa:phablet-team/tools
sudo add-apt-repository --yes ppa:phablet-team/tools
echo "Ubuntu Touch Developer Preview Tools repository added"

sudo add-apt-repository --remove --yes ppa:linaro-maintainers/tools
sudo add-apt-repository --yes ppa:linaro-maintainers/tools
echo "Linaro ATools repository added"

# Update 
echo "Running apt-get update"
sudo apt-get --yes update
sleep 2
echo "Killing Previous dpkg instances"
sudo pkill -9 dpkg

echo "Auto Accepting Sun License for jdk5 and 6"
sudo echo sun-java5-bin	shared/accepted-sun-dlj-v1-1 select true | sudo /usr/bin/debconf-set-selections -v
# Install both jdk's you never know when you might need to build Pre Gingerbread
echo -e "Installing Java\nInstalling sun-java5-jdk" 
sudo apt-get --yes install sun-java5-jdk
echo "Installing sun-java6-jdk" 
sudo apt-get --yes install sun-java6-jdk 
# Install java 7 from wepupd8
echo "Auto Accepting Oracle License"
sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections -v
echo "Installing oracle-java7-installer" 
sudo apt-get --yes  install oracle-java7-installer
# Install java 6 from wepupd8
# oracle-java6-installer is a newer version of sun-java6-jdk
# we "need" both version to maintain the ability to build all versions
# of Android on a single OS. 
echo "Installing oracle-java6-installer" 
sudo apt-get --yes  install oracle-java6-installer

# Install ant for build sdk based apps
echo "Installing apache ant" 
sudo apt-get --yes  install ant

# GCC - We install multiple versions of gcc so we can use the same Operating System Version
# to build all versions of Android - gcc 4.4 is capable of building early version of Android
# without having to apply ridiculous patches which are never going to be submitted upstream
# to the Android Main Code base  
# 
# update-alternative ( aka debian-alternatives ) is a mechanism which always easy switching 
# between different versions of the same file. In this case we have made g++ a slave to gcc 
# This keeps the binaries in sync with each other.
# 
# To switch between versions use : sudo update-alternatives --config gcc
#
echo "Installing GCC 4.4"
sudo apt-get --yes install gcc-4.4 gcc-4.4-multilib g++-4.4 g++-4.4-multilib
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.4 20 --slave /usr/bin/g++ g++ /usr/bin/g++-4.4
echo "Installing GCC 4.6"
sudo apt-get --yes install gcc-4.6 gcc-4.6-multilib g++-4.6 g++-4.6-multilib
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 40 --slave /usr/bin/g++ g++ /usr/bin/g++-4.6
echo "Installing GCC 4.7"
sudo apt-get --yes install gcc-4.7 gcc-4.7-multilib g++-4.7 g++-4.7-multilib
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.7

#
#
#



# Baseline AOSP Tool List
# Note: Again Ignoring any official documentation which suggests installing
# architecture based packages ( ending in :i386 ) this is insanity if
# you want a coherant system after 6 months or need to build anything other
# than Android

# Instead of i386 packages we get the multi-arch compatible 32* versions
echo "Installing Required 32bit libraries"
sudo apt-get --yes install lib32ncurses5-dev lib32readline6-dev lib32z1-dev libc6-dev-i386 lib32stdc++6 

# The build-essential packages contains a list of packages essential for building
# debian but not really! see the package information for further details
# This list contains the following:
# base-files base-passwd bash bsdutils coreutils dash debianutils diffutils dpkg
# e2fsprogs findutils grep gzip hostname libc-bin login mount ncurses-base ncurses-bin
# perl-base sed tar util-linux
# Additional the following development packages are installed
# bison         - LALR to C - context free grammar parser
# libc6-dev     - Standard C Library headers
# g++-multilib  - GNU C++ compiler with support for the non-default architecture
#                 In simple terms allow compiling of 32bit binaries on 64bit systems
# mingw32       - A Linux hosted win32 cross compiler, used if you need to compile
#               - the windows version of the sdk
echo "Installing Build Essential MetaPackage"
sudo apt-get --yes install build-essential 

echo "Installing Latest Cross Compilers and Multilib Utils"
sudo apt-get --yes install libc6-dev g++-multilib mingw32 mingw-w64

sudo apt-get --yes install git-core gnupg flex bison  gperf  \
  curl  libx11-dev  libgl1-mesa-glx x11proto-core-dev \
  libgl1-mesa-dev tofrodos python-markdown \
  libxml2-utils xsltproc 

# Install texinfo just incase your manufacturer thinks it's a good
# idea to realease there GPL obligations in the form of a BuildRoot 
# Package *cough* Archos *cough*
echo "Installing autotools, makeinfo and ffmpeg"
sudo apt-get ---yes install texinfo
# ... and autotools
sudo apt-get ---yes install autotools
# ... and ffmpeg
sudo apt-get ---yes install ffmpeg


## Ubuntu Touch Recommended Tools 
## phablet-tools        - This contains the following programs 
## phablet-demo-setup phablet-dev-bootstrap  phablet-network-setup  
## phablet-test-run phablet-flash repo
echo "Installing Recommended Ubuntu Touch Development Tools"
sudo apt-get ---yes install phablet-tools android-tools-adb android-tools-fastboot \
schedtool ubuntu-dev-tools

## Additional Tools
# lzop          - Required if you want to enable lzo compression when building a kernel
#                 as part of a Cyanogenmod installation
echo "Installing lzop lzma zip xz archive support"
sudo apt-get --yes install lzop zip xz-utils zlib1g-dev p7zip-full
 
echo "Installing linaro-image-tools"
sudo apt-get --yes  install linaro-image-tools 
fi
shift
echo "Creating udev [ /etc/udev/rules.d/51-android.rules ] rules for known android devices"
# Create a 51-android.rules for udev - using all known vendors
sudo sh -c "echo '
# /etc/udev/rules.d/51-android.rules - generated by init_android_dev.sh
# sudo udevadm control --reload-rules

# Fly - Vendorid 0x1782
SUBSYSTEM==\"usb"\, ATTR{idVendor}==\"1782\", MODE=\"0666\", OWNER=\"1000\"
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", MODE=\"0666\", OWNER=\"1000\"' \
> /etc/udev/rules.d/51-android.rules"

# Restart udev so we can get busy straight away
echo "Reloading udev rules"
sudo udevadm control --reload-rules

if [ ! -f /usr/bin/repo ] ; then 
        # download the repo tool if needed
        echo "Downloading repo"
        sudo sh -c "curl https://dl-ssl.google.com/dl/googlesource/git-repo/repo > /usr/bin/repo"
        sudo chmod 755 /usr/bin/repo
fi

#

#http://dl.google.com/android/adt/adt-bundle-linux-x86_64-20130522.zip
#echo "Downloading Android Studio"
#sudo mkdir -p /var/cache/android-studio -m 0755

#if [ ! -f $ANDROID_STUDIO_BUNDLE_PATH ] ; then 
#        sudo sh -c "curl http://dl.google.com/android/studio/$ANDROID_STUDIO_BUNDLE_FILENAME > $ANDROID_STUDIO_BUNDLE_PATH"
#fi

#sudo tar  --extract --verbose --gunzip --file $ANDROID_STUDIO_BUNDLE_PATH --directory /var/cache


