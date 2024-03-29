#!/bin/sh -e
# git-cache-meta -- file owner and permissions caching, minimalist approach
: ${GIT_CACHE_META_FILE=.git_cache_meta} #simpler not to git-add it
case $@ in
    --store|--stdout)
 case $1 in --store) exec > $GIT_CACHE_META_FILE; esac
 git ls-files|xargs -I{} find {} \
     \( -user ${USER?} -o -printf "chown %u '%p'\n" \) \
	 \( -group $(id -gn) -o -printf "chgrp %g '%p'\n" \) \
     \( \( -type l -o -perm 755 -o -perm 644 \) \
     -o -printf "chmod %#m '%p'\n" \);;#requires GNU Find
    --apply) sh -e $GIT_CACHE_META_FILE;;
    *) 1>&2 cat <<EOF; exit 1;;
Usage: $0 --store|--stdout|--apply #Example:
# git bundle create mybundle.bdl master; git-cache-meta --store
# scp mybundle.bdl .git_cache_meta machine2: #then on machine2:
# git init; git pull mybundle.bdl master; git-cache-meta --apply
EOF
esac
