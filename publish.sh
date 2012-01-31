#!/bin/bash 

if [ $# -eq 0 ]; then
  echo 'you must have something to publish' >2
  exit 1
fi

root=$(
  cd $(dirname $0)
  /bin/pwd
)

dir=$1
out=/tmp/effectivescala.$$

trap "rm -fr $out" 0 1 2

git clone $root/.git $out
cd $out
git remote set-url origin git@github.com:twitter/effectivescala.git
git fetch
git co gh-pages
cd $root
cp $* $out/
cd $out
git add .
git commit -am"publish by $USER"
git push origin gh-pages
