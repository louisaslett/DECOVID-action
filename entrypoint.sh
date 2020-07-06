#!/bin/bash

#chg=$(git diff-tree --no-commit-id --name-only -r HEAD |
chg=$(git diff --name-only HEAD~1 |
  grep -E "^data-request-forms/([^/]+)/[^/]+$" |
  sed -E "s;^data-request-forms/([^/]+)/[^/]+$;\1;" |
  uniq)

echo $chg

if [ -z "$chg" ]; then
  echo "No DRF changes detected"
  exit 0
fi

cd data-request-forms/template
drfQ=$(ls -1)
cd ..

git config --local user.email "DECOVID-action@master"
git config --local user.name "louis.bot"
git checkout $GITHUB_HEAD_REF
git remote set-url origin https://x-access-token:${INPUT_GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}

while x= read -r drf; do
  echo "... $drf ..."

  cp -r $drf ${drf}_process
  cd ${drf}_process
  sed -i '/^#/d' *.md
  sed -i 's/^/> /' *.md
  cp * ..
  cd ..
  wc * > wc.dat

  Rscript DRF.R

  mv DRF.pdf ${drf}_DRF.pdf
  mv DRF.html ${drf}_DRF.html
  mv DRF.md ${drf}_DRF.md

  git add ${drf}_DRF.md
  git commit -m ":rocket: Autogen of ${drf} DRF ... :robot:"
  git push origin $GITHUB_HEAD_REF

  curl -F file=@${drf}_DRF.pdf -F channels=#drf -H "Authorization: Bearer ${INPUT_SLTK}" https://slack.com/api/files.upload

  rm wc.dat *.csv A* B* C*; rm -rf ${drf}_process; #rm *.pdf; rm *.html;
done <<< "$chg"
