#!/bin/bash

pwd
ls -al
echo "==="
git status -v
echo "==="
echo $GITHUB_SHA
echo "==="
git log|head
echo "==="
#git diff-tree --no-commit-id --name-only -r HEAD
git diff --name-only HEAD~1
echo "==="

#chg=$(git diff-tree --no-commit-id --name-only -r HEAD |
chg=$(git diff --name-only HEAD~1 |
  grep -E "^DRFs/([^/]+)/[^/]+$" |
  sed -E "s;^DRFs/([^/]+)/[^/]+$;\1;" |
  uniq)

echo $chg

if [ -z "$chg" ]; then
  echo "No DRF changes detected"
  exit 0
fi

drfQ=('A1_project_title.md' 'A2_research_questions_and_aims.md')

cd DRFs
while x= read -r drf; do
  echo "... $drf ..."

  cp -r $drf ${drf}_process
  cd ${drf}_process
  sed -i '/^#/d' *.md
  sed -i 's/^/> /' *.md
  cp *.md ..
  cd ..
  wc * > wc.dat

  Rscript DRF.R

  mv DRF.pdf ${chg}_DRF.pdf
  mv DRF.html ${chg}_DRF.html

  curl -F file=@${chg}_DRF.pdf -F channels=#drf -H "Authorization: Bearer ${INPUT_SLTK}" https://slack.com/api/files.upload

  rm *.md; rm wc.dat; rm *.pdf; rm *.html; rm -rf ${drf}_process;
done <<< "$chg"
