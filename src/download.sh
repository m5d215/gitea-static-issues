#!/bin/bash

set -e
set -u

# requires
[ -n "${GITEA_URL:-}" ]
[ -n "${REPO:-}" ]

mkdir -p static/assets/badges
mkdir -p static/assets/gitea-images
mkdir -p static/json

function __log()
{
    echo "$@"
}

# stdout: number[] -- valid page numbers
function enumerate_pages()
{
    local _count

    # Get largest issue number.
    _count=$(curl -ns "$GITEA_URL/api/v1/repos/$REPO/issues?state=all&page=1" | jq -cMr '. | sort_by(.number) | reverse[0].number')

    # Paginated every 10 pages.
    seq 1 "$(( (_count + 9) / 10 ))"
}

# stdin: number[]  -- page numbers
# stdout: Issue[]  -- issues in JSON format
function download_issues()
{
    xargs -I {} curl -ns "$GITEA_URL/api/v1/repos/$REPO/issues?state=all&page={}" | jq -cMr '.[]'
}

# stdin: Issue -- issue in JSON format
function save_issue()
{
    local _id
    local _comments
    local _json

    {
        read -r _id
        read -r _comments
        read -r _json
    } < <(jq -cMr '[.number, .comments, .][]')

    __log "#$_id ($_comments comments)"
    {
        echo "$_json"
        if (( _comments != 0 )); then
            curl -ns "$GITEA_URL/api/v1/repos/$REPO/issues/$_id/comments"
        else
            echo '[]'
        fi
    } | jq -Ms '.[0] + { comments: .[1] }' >"static/json/$_id.json"
}

# stdin: Issue   -- issue in JSON format
# stdout: URL[]  -- image URLs
function extract_image_urls()
{
    jq -cMr .body | grep -oE '!\[.*?\]\(.*?\)' | sed -E 's/^!\[.*\]\((.*)\)/\1/g'
}

# stdin: URL[] -- image URLs
function download_and_save_images()
{
    local _url

    while read -r _url
    do
        __log "  $_url"
        curl -ns "$_url" -o "static/assets/gitea-images/${_url##*/}" || :
    done < <(grep -E "^$GITEA_URL/attachments/")
}

while read -r _issue
do
    save_issue <<<"$_issue"
    extract_image_urls <<<"$_issue" | download_and_save_images
done < <(enumerate_pages | download_issues)

# stdout: Label[] -- labels in JSON format
function download_labels()
{
    curl -ns "$GITEA_URL/api/v1/repos/$REPO/labels" | jq -cMr '.[]'
}

# stdin: Issue -- label in JSON format
function save_label()
{
    local _name
    local _color

    {
        read -r _name
        read -r _color
    } < <(jq -cMr '[.name, .color][]')

    __log "label: $_name"
    curl -s "https://badgen.net/badge/label/$_name/$_color" -o "static/assets/badges/label-$_name.svg"
}

while read -r _label
do
    save_label <<<"$_label"
done < <(download_labels)

curl -s https://badgen.net/badge/pull/open/blue?icon=git -o static/assets/badges/pull-open.svg
curl -s https://badgen.net/badge/pull/closed/blue?icon=git -o static/assets/badges/pull-closed.svg
curl -s https://badgen.net/badge/issue/open/blue?icon=git -o static/assets/badges/issue-open.svg
curl -s https://badgen.net/badge/issue/closed/blue?icon=git -o static/assets/badges/issue-closed.svg
