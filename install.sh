#! /bin/sh

cd ~/
git clone https://github.com/L-Zephyr/Drafter.git
cd Drafter
swift build -c release -Xswiftc -static-stdlib
cp -f -r ./Template/ ~/.drafter
cd .build/release
cp -f drafter /usr/local/bin/drafter
cd ~/
rm -rf Drafter