#!/usr/bin/env bash
CI=1 npx antora --fetch antora-playbook.yml
(cd ../gh-pages && git add * && git commit -a -m 'Publish.' && git push)
