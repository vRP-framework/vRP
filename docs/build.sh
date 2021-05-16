#!/bin/bash

stylesheet=$1

gen(){
  asciidoctor $1 -D $2 \
  -a source-highlighter=highlight.js -a icons=font \
  -a stylesheet=$stylesheet
}
  
gen ../doc/index.adoc .
gen ../doc/dev/index.adoc dev/
