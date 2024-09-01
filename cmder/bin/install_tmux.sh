#!/usr/bin/env bash

export tmux_ver=${1:-3.2.a-1}
export libevent_ver=${2:-2.1.12-2}
export zsh_ver=${3:-5.9.1}

export arch=${4:-x86_64}

[[ -f /tmp/zstd.zip ]] && rm -f /tmp/zstd.zip
[[ -d /tmp/zstd_Win32 ]] && rm -rf /tmp/zstd_Win32

ls -la /tmp |grep zst

curl -Lko /tmp/zstd.zip https://downloads.sourceforge.net/project/zstd-for-windows/zstd_Windows7%5BMinGW%5D%28static%29.zip?ts=gAAAAABjUce39lZxqUQ7zjZRoMyz3QNG7qlkwDNxopc6BWKtzWjATuGdYh09qrrX49lTZX1nJc7n3klJYnDq4Obuj2ZjLFgxlA%3D%3D&r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fzstd-for-windows%2Ffiles%2Fzstd_Windows7%255BMinGW%255D%2528static%2529.zip%2Fdownload
sleep 3

cd /tmp
ls /tmp/zstd.zip
unzip /tmp/zstd.zip
ls -la /tmp/zstd_Win32
sleep 3

curl -Lko /tmp/tmux-${tmux_ver}-${arch}.pkg.tar.zst https://repo.msys2.org/msys/${arch}/tmux-${tmux_ver}-${arch}.pkg.tar.zst
curl -Lko /tmp/libevent-${libevent_ver}-${arch}.pkg.tar.zst https://repo.msys2.org/msys/${arch}/libevent-${libevent_ver}-${arch}.pkg.tar.zst
curl -Lko /tmp/zsh-${zsh_ver}-${arch}.pkg.tar.zst https://repo.msys2.org/msys/x86_64/zsh-5.9-1-x86_64.pkg.tar.zst

/tmp/zstd_Win32/zstd.exe -df /tmp/tmux-${tmux_ver}-${arch}.pkg.tar.zst
/tmp/zstd_Win32/zstd.exe -df /tmp/libevent-${libevent_ver}-${arch}.pkg.tar.zst
/tmp/zstd_Win32/zstd.exe -df /tmp/zsh-${zsh_ver}-${arch}.pkg.tar.zst

sleep 3
cd /

tar -xvf /tmp/tmux-${tmux_ver}-${arch}.pkg.tar
tar -xvf /tmp/libevent-${libevent_ver}-${arch}.pkg.tar
tar -xvf /tmp/zsh-${zsh_ver}-${arch}.pkg.tar



