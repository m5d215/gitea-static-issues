GITEA_URL ?= http://try.gitea.io
REPO      ?= owner/name

JSON = $(shell [ ! -d static/json ] || find static/json -type f -name '*.json' | sort -n -t / -k 3)
MD   = $(JSON:static/json/%.json=static/md/%.md)

build: md html

download:
	@GITEA_URL=$(GITEA_URL) REPO=$(REPO) src/download.sh
	@find static/json -type f -name '*.json' ! -name index.json -print | sort -n -t / -k 3 | xargs cat | jq -s 'del(.[].body)' >static/json/index.json

md: $(MD)

html:
	@node_modules/.bin/generate-md --layout mixu-bootstrap-2col --input static/md --output static/html

clean:
	@rm -rf static

.PHONY: build download md html clean

static/md/%.md: static/json/%.json
	@echo $@
	@mkdir -p static/md
	@node_modules/.bin/mustache -p src/pull-or-issue.mustache $< src/issue.md.mustache | sed -E 's#$(GITEA_URL)/attachments/#../assets/gitea-images/#g' >$@

static/md/index.md: static/json/index.json
	@echo $@
	@mkdir -p static/md
	@node_modules/.bin/mustache -p src/pull-or-issue.mustache $< src/index.md.mustache >$@
