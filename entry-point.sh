#!/bin/sh

# カレントディレクトリの uid と gid を調べる
uid=$(stat -c "%u" .)
gid=$(stat -c "%g" .)

if [ "$uid" -ne 0 ]; then
  if [ "$(id -g $USER)" -ne $gid ]; then
    # node ユーザーの gid とカレントディレクトリの gid が異なる場合、
    # node の gid をカレントディレクトリの gid に変更し、ホームディレクトリの
    # gid も正常化する。
    getent group $gid >/dev/null 2>&1 || groupmod -g $gid $USER
    chgrp -R $gid $HOME
  fi
  if [ "$(id -u $USER)" -ne $uid ]; then
    # node ユーザーの uid とカレントディレクトリの uid が異なる場合、
    # node の uid をカレントディレクトリの uid に変更する。
    # ホームディレクトリは usermod によって正常化される。
    usermod -u $uid $USER
  fi
fi

# このスクリプト自体は root で実行されているので、uid/gid 調整済みの node ユーザー
# として指定されたコマンドを実行する。
exec gosu $USER "$@"
