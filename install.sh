#! /bin/sh

cd ~/
git clone https://github.com/L-Zephyr/Drafter.git
cd Drafter

# check if static link is needed
if [ -d "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift_static/macosx" ];then
    swift build -c release -Xswiftc -static-stdlib
else
    swift build -c release
fi

unzip -o ./Template/template.zip -d ./Template/drafter
cp -f -r ./Template/drafter/template/ ~/.drafter
cd .build/release
cp -f drafter /usr/local/bin/drafter
cd ~/
rm -rf Drafter
