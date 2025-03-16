FROM node:23-bullseye

# tsx と npm をグローバルインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
  gosu

ENV USER=node
ENV NPM_CONFIG_CACHE=/home/$USER/.npm
ENV NPM_CONFIG_PREFIX=/home/$USER/.npm-global
COPY entry-point.sh /

RUN gosu $USER npm install -g npm@11.2.0 tsx --no-cache
ENV PATH=$NPM_CONFIG_PREFIX/bin:$PATH

ENTRYPOINT [ "/entry-point.sh" ]
