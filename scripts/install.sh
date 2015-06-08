if [ ! -e haxe-3.2.0 ]
then
  wget http://haxe.org/website-content/downloads/3.2.0/downloads/haxe-3.2.0-linux32.tar.gz
  tar xvzf haxe-3.2.0-linux32.tar.gz
fi
PATH=./haxe-3.2.0:$PATH

