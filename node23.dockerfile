FROM node:23-bullseye

# tsx と npm をグローバルインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
  gosu

# npm を最新版にする
RUN npm install -g npm@11.2.0 --no-cache

ARG USER=node
ENV USER=$USER
ENV NPM_CONFIG_CACHE=/home/$USER/.npm
ENV NPM_CONFIG_PREFIX=/home/$USER/.npm-global
COPY entry-point.sh /

# node ユーザーでインストールしたいパッケージ
RUN gosu $USER npm install -g tsx --no-cache

ENTRYPOINT [ "/entry-point.sh" ]
