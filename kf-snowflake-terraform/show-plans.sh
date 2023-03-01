#!/bin/sh

set -e -o pipefail
if [ ! -z $DEBUG ]; then
    set -o xtrace
fi

PLANS=`realpath plans`

echo '```term'
for d in *; do
    if [ -d $d ] && [ -f "${d}/main.tf" ]; then
        echo "$d"
        echo "-------------------------------------------------------------------"
        planfile="${PLANS}/${d}.tfplan"
        sh -c "cd $d && terraform show $planfile $@"
        echo && echo
    fi
done
echo '```'
