sudo apt-get install byacc flex
wget http://spinroot.com/spin/Src/spin646.tar.gz
cp spin*.tar.gz  /opt/
cd /opt/
tar -zxvf spin*.tar.gz
cd spin*/Spin
cd Src*
sudo make
