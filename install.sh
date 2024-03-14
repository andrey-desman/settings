#/bin/bash

relpath()
{
  #!/bin/bash
  # both $1 and $2 are absolute paths
  # returns $2 relative to $1

  src=$1
  tgt=$2

  common_part=$src
  back=
  while [ "${tgt#$common_part}" = "${tgt}" ]; do
    common_part=$(dirname $common_part)
    back="../${back}"
  done

  echo ${back}${tgt#$common_part/}
}

home=$(readlink -f ~)

targets="$(find . -maxdepth 1 -mindepth 1 \! -name ".git" -a \! -name ".gitignore" -a \! -name "install.sh" -a \! -name ".git_cache_meta" -a \! -name "perm.sh")"

for f in $targets; do
  item=$(relpath $home $(readlink -f $f))
  target=$home/$(basename $item)
  if [ -L $target ]; then
    rm $target
  else
    rm -rf $target
  fi
  ln -s -f $item $target
done

./perm.sh --apply
