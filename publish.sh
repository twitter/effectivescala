#!/bin/bash 

if [ $# -eq 0 ]; then
  echo 'you must have something to publish' 1>&2
  exit 1
fi

for f; do
  if [ ! -f $f ]; then
    echo $f' is not a valid file!' 1>&2
    exit 1
  fi
done

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
