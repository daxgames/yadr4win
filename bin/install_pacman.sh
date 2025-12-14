#!/usr/bin/env bash

# Based on: https://github.com/mcgitty/pacman-for-git
# My Fork: https://github.com/daxgames/pacman-for-git

if [[ "$HOSTTYPE" == "i686" ]]; then
  pacman=(
    pacman-6.0.0-4-i686.pkg.tar.zst
    pacman-mirrors-20210703-1-any.pkg.tar.zst
    msys2-keyring-1~20210213-2-any.pkg.tar.zst
  )

 zstd=zstd-1.5.0-1-i686.pkg.tar.xz
 zstd_win=https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-v1.5.5-win32.zip
else
  pacman=(
    pacman-6.0.1-18-x86_64.pkg.tar.zst
    pacman-mirrors-20220205-1-any.pkg.tar.zst
    msys2-keyring-1~20220623-1-any.pkg.tar.zst
  )

  zstd=zstd-1.5.2-1-x86_64.pkg.tar.xz
  zstd_win=https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-v1.5.5-win64.zip
fi

export bin_source=https://github.com/daxgames/pacman-for-git/raw/refs/heads/main

echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo Downloading pacman files...
echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
for f in ${pacman[@]}; do
  echo "Running: curl ${bin_source}/$f -Lkfo ~/Downloads/$f"
  curl ${bin_source}/$f -sLkfo ~/Downloads/$f || exit 1
done

echo -e "\n=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"

echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo Downloading zstd binaries...
echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo "Running: curl -Lk ${bin_source}/$zstd -o ~/Downloads/$zstd"
curl -sLk ${bin_source}/$zstd -o ~/Downloads/$zstd || exit 1
echo "Running: curl -Lk $zstd_win -o ~/Downloads/$(basename ${zstd_win})"
curl -sLk $zstd_win -o ~/Downloads/$(basename ${zstd_win}) || exit 1

echo -e "\n=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"

echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo Downloading pacman.conf...
echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo "Running: curl -Lk https://raw.githubusercontent.com/msys2/MSYS2-packages/7858ee9c236402adf569ac7cff6beb1f883ab67c/pacman/pacman.conf"
curl -sLk https://raw.githubusercontent.com/msys2/MSYS2-packages/7858ee9c236402adf569ac7cff6beb1f883ab67c/pacman/pacman.conf -o /etc/pacman.conf || exit 1

pushd ~/Downloads
unzip ~/Downloads/$(basename ${zstd_win})
PATH=$PATH:~/Downloads/$(basename ${zstd_win} | sed 's/.zip$//')
popd

echo -e "\n=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"

cd /
echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo Installing pacman files...
echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo "Extracting zstd to /usr..."
    tar x --xz -vf ~/Downloads/$zstd usr

for f in ${pacman[@]}; do
  echo "Extracting $f to /usr and /etc..."
  tar x --zstd -vf ~/Downloads/$f usr etc 2>/dev/nul
done

echo -e "\n=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"

echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo Initializing pacman...
echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
mkdir -p /var/lib/pacman
ln -sf "`which gettext`" /usr/bin/
pacman-key --init
pacman-key --populate msys2
pacman -Syu --noconfirm

echo -e "\n=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"

echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo Getting package versions for the installed Git release
echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
t=`grep -E 'mingw-w64-[ix_0-9]+-git ' /etc/package-versions.txt`

echo "Getting commit ID that matches '$t' from github pacman-for-git..."
t=`curl -sLk ${bin_source}/version-tags.txt|grep "$t"`

echo -e "Using commit ID: '${t##* }'"
[[ "$t" == "" ]] && echo "ERROR: Commit ID not logged in github pacman-for-git." && exit 1
echo -e "Using commit ID: ${t##* }"

echo -e "\n=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"

echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
echo Downloading package database files for the installed Git release
echo =-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
b=64 && [[ "$t" == *-i686-* ]] && b=32
URL=https://github.com/git-for-windows/git-sdk-$b/raw/${t##* }
cat /etc/package-versions.txt | while read p v; do d=/var/lib/pacman/local/$p-$v;
 mkdir -p $d; echo $d; for f in desc files mtree; do curl -fsSL "$URL$d/$f" -o $d/$f;
 done; [[ ! -f $d/desc ]] && rmdir $d && echo Missing $d; done

echo -e "\n=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-\n"
