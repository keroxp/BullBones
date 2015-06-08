#!/bin/sh


HAXE_VERSION=3.2.0
HAXE_VERSION_COMMA=3,2,0
NEKO_VERSION=2.0.0


if [ "$1" = "y" -o "$1" = "-y" ]; then

  echo "Do you want to install Haxe $HAXE_VERSION and Neko $NEKO_VERSION? (y/n) y"
  RESP=y

else

  read -p "Do you want to install Haxe $HAXE_VERSION and Neko $NEKO_VERSION? (y/n) " RESP

fi


if [ $RESP = "y" ]; then


  if [ -n "$(command -v yum)" ]; then

    echo ""
    echo "---------------------------------------"
    echo "    Installing Dependencies"
    echo "---------------------------------------"

    sudo yum -y install wget

  elif [ -n "$(command -v pacman)" ]; then

    echo ""
    echo "---------------------------------------"
    echo "    Installing Dependencies"
    echo "---------------------------------------"

    set -e
    sudo pacman -S wget --noconfirm

  elif [ -n "$(command -v apt-get)" ]; then

    echo ""
    echo "---------------------------------------"
    echo "    Removing Haxe (if installed)"
    echo "---------------------------------------"

    set +e
    sudo apt-get remove haxe neko
    set -e

  fi


  if [ `uname -m` = "x86_64" ]; then


    echo ""
    echo "---------------------------------------"
    echo "    Downloading Neko $NEKO_VERSION (64-bit)"
    echo "---------------------------------------"

    wget -c http://nekovm.org/_media/neko-$NEKO_VERSION-linux64.tar.gz


    echo ""
    echo "---------------------------------------"
    echo "    Installing Neko $NEKO_VERSION"
    echo "---------------------------------------"

    # Extract and copy files to /usr/lib/neko

    tar xvzf neko-$NEKO_VERSION-linux64.tar.gz
    sudo mkdir -p /usr/lib/neko
    sudo rm -rf /usr/lib/neko/neko
    sudo rm -rf /usr/lib/neko/nekotools
    sudo cp -r neko-$NEKO_VERSION-linux/* /usr/lib/neko

    # Add symlinks

    sudo rm -rf /usr/bin/neko
    sudo rm -rf /usr/bin/nekoc
    sudo rm -rf /usr/bin/nekotools
    sudo rm -rf /usr/lib/libneko.so

    sudo ln -s /usr/lib/neko/libneko.so /usr/lib/libneko.so
    sudo ln -s /usr/lib/neko/neko /usr/bin/neko
    sudo ln -s /usr/lib/neko/nekoc /usr/bin/nekoc
    sudo ln -s /usr/lib/neko/nekotools /usr/bin/nekotools

    if [ -d "/usr/lib64" ]; then

      set +e
      sudo rm -rf /usr/lib64/libneko.so
      sudo ln -s /usr/lib/neko/libneko.so /usr/lib64/libneko.so
      set -e

    fi

    # Cleanup

    rm -rf neko-$NEKO_VERSION-linux
    rm neko-$NEKO_VERSION-linux64.tar.gz


  else


    echo ""
    echo "--------------------------------------"
    echo "    Downloading Neko $NEKO_VERSION (32-bit)"
    echo "---------------------------------------"

    wget -c http://nekovm.org/_media/neko-$NEKO_VERSION-linux.tar.gz


    echo ""
    echo "---------------------------------------"
    echo "    Installing Neko $NEKO_VERSION"
    echo "---------------------------------------"


    # Extract and copy files to /usr/lib/neko

    tar xvzf neko-$NEKO_VERSION-linux.tar.gz
    sudo mkdir -p /usr/lib/neko
    sudo rm -rf /usr/lib/neko/neko
    sudo rm -rf /usr/lib/neko/nekotools
    sudo cp -r neko-$NEKO_VERSION-linux/* /usr/lib/neko

    # Add symlinks

    sudo rm -rf /usr/bin/neko
    sudo rm -rf /usr/bin/nekoc
    sudo rm -rf /usr/bin/nekotools
    sudo rm -rf /usr/lib/libneko.so

    sudo ln -s /usr/lib/neko/neko /usr/bin/neko
    sudo ln -s /usr/lib/neko/nekoc /usr/bin/nekoc
    sudo ln -s /usr/lib/neko/nekotools /usr/bin/nekotools
    sudo ln -s /usr/lib/neko/libneko.so /usr/lib/libneko.so


    # Cleanup

    rm -rf neko-$NEKO_VERSION-linux
    rm neko-$NEKO_VERSION-linux.tar.gz


  fi


  # Install libgc, which is required for Neko

  if [ -n "$(command -v yum)" ]; then

    sudo yum -y install libgc

  elif [ -n "$(command -v pacman)" ]; then

    sudo pacman -S gc --noconfirm

  elif [ -n "$(command -v zypper)" ]; then

    sudo zypper --non-interactive install libgc1

  else

    sudo apt-get -y install libgc-dev

  fi

  if [ -d "/usr/lib64" ] && [ ! -f "/usr/lib64/libpcre.so.3" ]; then

    set +e
    sudo ln -s /usr/lib64/libpcre.so.1 /usr/lib64/libpcre.so.3
    set -e

  fi


  if [ `uname -m` = "x86_64" ]; then


    echo ""
    echo "---------------------------------------"
    echo "    Downloading Haxe $HAXE_VERSION (64-bit)"
    echo "---------------------------------------"

    wget -c http://haxe.org/website-content/downloads/$HAXE_VERSION_COMMA/downloads/haxe-$HAXE_VERSION-linux64.tar.gz


    echo ""
    echo "---------------------------------------"
    echo "    Installing Haxe $HAXE_VERSION"
    echo "---------------------------------------"


    # Extract and copy files to /usr/lib/haxe

    sudo mkdir -p /usr/lib/haxe
    sudo rm -rf /usr/lib/haxe/haxe
    sudo tar xvzf haxe-$HAXE_VERSION-linux64.tar.gz -C /usr/lib/haxe --strip-components=1


    # Add symlinks

    sudo rm -rf /usr/bin/haxe
    sudo rm -rf /usr/bin/haxelib
    sudo rm -rf /usr/bin/haxedoc

    sudo ln -s /usr/lib/haxe/haxe /usr/bin/haxe
    sudo ln -s /usr/lib/haxe/haxelib /usr/bin/haxelib


    # Set up haxelib

    sudo mkdir -p /usr/lib/haxe/lib
    sudo chmod -R 777 /usr/lib/haxe/lib
    haxelib setup /usr/lib/haxe/lib


    # Cleanup

    rm haxe-$HAXE_VERSION-linux64.tar.gz


  else


    echo ""
    echo "---------------------------------------"
    echo "    Downloading Haxe $HAXE_VERSION (32-bit)"
    echo "---------------------------------------"

    wget -c http://haxe.org/website-content/downloads/$HAXE_VERSION_COMMA/downloads/haxe-$HAXE_VERSION-linux32.tar.gz


    echo ""
    echo "---------------------------------------"
    echo "    Installing Haxe $HAXE_VERSION"
    echo "---------------------------------------"


    # Extract and copy files to /usr/lib/haxe

    sudo mkdir -p /usr/lib/haxe
    sudo rm -rf /usr/lib/haxe/haxe
    sudo tar xvzf haxe-$HAXE_VERSION-linux32.tar.gz -C /usr/lib/haxe --strip-components=1


    # Add symlinks

    sudo rm -rf /usr/bin/haxe
    sudo rm -rf /usr/bin/haxelib
    sudo rm -rf /usr/bin/haxedoc

    sudo ln -s /usr/lib/haxe/haxe /usr/bin/haxe
    sudo ln -s /usr/lib/haxe/haxelib /usr/bin/haxelib


    # Set up haxelib

    sudo mkdir -p /usr/lib/haxe/lib
    sudo chmod -R 777 /usr/lib/haxe/lib
    sudo haxelib setup /usr/lib/haxe/lib


    # Cleanup

    rm haxe-$HAXE_VERSION-linux32.tar.gz


  fi


fi


echo ""
