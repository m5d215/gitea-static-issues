# gitea-static-issues

![size and layers](https://images.microbadger.com/badges/image/m5d215/gitea-static-issues.svg)

Export [Gitea](https://gitea.io) issues in json/md/html format.

![screenshot](https://github.com/m5d215/gitea-static-issues/raw/master/screenshot.png)

## Features

- Export in JSON format
- Export in Markdown format
- Export in HTML format
- Export images hosted by Gitea
- Rich icons powered by [badgen.net](https://badgen.net)

## Requirements

- [`jq` command](https://stedolan.github.io/jq)
- Gitea instance

## Usage

```sh
yarn install

export GITEA_URL=https://try.gitea.io
export REPO=m5d215/gitea-static-issues

make download
make build
```

Run on docker.

```sh
docker container run \
    --rm \
    -v "$PWD/static:/static" \
    -e GITEA_URL=https://try.gitea.io \
    -e REPO=m5d215/gitea-static-issues \
    m5d215/gitea-static-issues:latest download

docker container run \
    --rm \
    -v "$PWD/static:/static" \
    -e GITEA_URL=https://try.gitea.io \
    -e REPO=m5d215/gitea-static-issues \
    m5d215/gitea-static-issues:latest build
```
