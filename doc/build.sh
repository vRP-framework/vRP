#!/usr/bin/env bash
params='
  -a source-highlighter=highlight.js -a icons=font
  -a stylesheet=stylesheet.css'

asciidoctor index.adoc -D ../gh-pages/ $params
asciidoctor dev/index.adoc -D ../gh-pages/dev/ $params -a stylesdir=../
