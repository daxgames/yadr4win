#!/usr/bin/env bash

if [[ "$HOSTTYPE" == "i686" ]]; then
 pacman="
pacman-6.0.0-4-i686.pkg.tar.zst
pacman-mirrors-20210703-1-any.pkg.tar.zst
msys2-keyring-1~20210213-2-any.pkg.tar.zst
"
 zstd=zstd-1.5.0-1-i686.pkg.tar.xz
 zstd_win=https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-v1.5.5-win32.zip
else
 pacman="
pacman-6.0.2-11-x86_64.pkg.tar.zst
pacman-mirrors-20221016-1-any.pkg.tar.zst
msys2-keyring-1~20231013-1-any.pkg.tar.zst
"
 zstd=zstd-1.5.5-1-x86_64.pkg.tar.xz
 zstd_win=https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-v1.5.5-win64.zip
fi
for f in $pacman; do
  curl https://repo.msys2.org/msys/$HOSTTYPE/$f -fo ~/Downloads/$f
done

curl -L https://github.com/mcgitty/pacman-for-git/raw/main/$zstd -o ~/Downloads/$zstd
curl https://raw.githubusercontent.com/msys2/MSYS2-packages/7858ee9c236402adf569ac7cff6beb1f883ab67c/pacman/pacman.conf -o /etc/pacman.conf
curl -Lk $zstd_win -o ~/Downloads/$(basename ${zstd_win})

pushd ~/Downloads
unzip ~/Downloads/$(basename ${zstd_win})
PATH=$PATH:~/Downloads/$(basename ${zstd_win} | sed 's/.zip$//')
popd

read -p "Press [Enter] to continue..."

cd /
set -x
tar x --zstd -vf ~/Downloads/$zstd usr
set +x
for f in $pacman; do 
  set -x
  tar x --zstd -vf ~/Downloads/$f usr etc 2>/dev/nul
  set +x
done

mkdir -p /var/lib/pacman
set -x
pacman-key --init
pacman-key --populate msys2
pacman-db-upgrade -d /var/lib/pacman
pacman -Syu
set +x

read -p "Press [Enter] to continue..."

t=`grep -E 'mingw-w64-[ix_0-9]+-git ' /etc/package-versions.txt`
t=`curl -sL https://github.com/mcgitty/pacman-for-git/raw/main/version-tags.txt|grep "$t"`
[[ "$t" == "" ]] && echo "ERROR: Commit ID not logged in github pacman-for-git." && read
b=64 && [[ "$t" == *-i686-* ]] && b=32
URL=https://github.com/git-for-windows/git-sdk-$b/raw/${t##* }
cat /etc/package-versions.txt | while read p v; do d=/var/lib/pacman/local/$p-$v;
 mkdir -p $d; echo $d; for f in desc files mtree; do curl -fsSL "$URL$d/$f" -o $d/$f;
 done; [[ ! -f $d/desc ]] && rmdir $d; done
