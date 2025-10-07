#!/bin/bash -eux

# https://stackoverflow.com/a/29888735
git rm --cached -r .
git reset --hard


for i in $(find . -name \*.sh); do
    dos2unix $i
    git add --renormalize $i
done
