#!/bin/sh -e

usage() { echo "Usage: $0 -t <template name> -s <stack name> -r <region>" 1>&2; exit 2; }

while getopts "t:s:r:" opt; do
    case $opt in
        t)
            templateName=$OPTARG #the folder or sample to deploy
        ;;
        s)
            stackName=$OPTARG
        ;;
        r)
            REGION=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

if [ -z "$templateName" ] || [ -z "$stackName" ]; then
    usage
fi

if [ -z "$REGION" ]; then
    REGION=$(aws configure get region)
fi

get_create_or_update() {
  if aws cloudformation describe-stacks --stack-name "$1" --region "$REGION" >/dev/null 2>&1 ; then
    echo "update"
  else
    echo "create"
  fi
}

mode="$(get_create_or_update "$stackName")"

DISABLE_ROLLBACK=""
echo $mode

if [ "$mode" == "create" ]; then
    DISABLE_ROLLBACK=" --disable-rollback"
fi

aws cloudformation "${mode}-stack" $DISABLE_ROLLBACK \
    --region "$REGION" \
    --template-body file://templates/${templateName}.yaml \
    --stack-name "$stackName" \
    --capabilities CAPABILITY_IAM \
    --parameters $@

aws --region "$REGION" cloudformation wait "stack-${mode}-complete" --stack-name "$stackName"