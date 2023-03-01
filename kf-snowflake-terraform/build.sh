#!/bin/sh

set -e -o pipefail
if [ ! -z DEBUG]; then
    set -o xtrace
fi

mkdir -p plans
TFVARS=`realpath terraform.tfvars`
PLANS=`realpath plans`

for d in *; do
    if [ -d $d ] && [ -f "${d}/main.tf" ]
        echo "Running 'plan' $d"
        planfile="${PLANS}/${d}.tfplan"
        sh -c "cd $d && terraform plan -var-file=${TFVARS} -out${planfile} $@"
    fi
done
