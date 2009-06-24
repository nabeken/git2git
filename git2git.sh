#!/bin/sh

function gettree {
    commit=$1
    dir=$2

    git ls-tree ${commit} | grep ${dir} | cut -d'	' -f1 | cut -d' ' -f3
}

function getmsg {
    commit=$1
    git log -1 --format=%s ${commit}
}

function commit_tree {
    tree=$1
    msg=$2
    parent=$3

    if [[ ! -z ${parent} ]]; then
	parent="-p ${parent}"
    fi

    echo ${msg} | /usr/libexec/git-core/git-commit-tree ${tree} ${parent}
}

dir=$1
branch=$2

origin_head=$(git log --reverse --format=%H ${dir} | head -n1)

msg=$(getmsg ${origin_head})

tree=$(gettree ${origin_head} ${dir})

parent=$(commit_tree "${tree}" "${msg}")

for i in $(git log --format=%H --reverse HEAD -- ${dir} | tail -n+2); do
    echo $i > /dev/stderr
    msg=$(getmsg ${i})
    tree=$(gettree $i ${dir})
    parent=$(commit_tree "${tree}" "${msg}" "${parent}")
done

git update-ref refs/heads/${branch} ${parent}
