#!/bin/sh

set -e

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

# Create a dedicated profile for this action to avoid conflicts
# with past/future actions.
aws configure --profile react-deploy-to-s3-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF


# 
source="${SOURCE_DIR:-build}"

#  Sync using our dedicated profile and suppress verbose messages.
#   - Upload index first.
#   - Then the other top level files.
#   - Then the static files.
sh -c "aws s3 sync ${source}/index.html s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --profile react-deploy-to-s3-action \
              --metadata-directive REPLACE \
              --cache-control max-age=5 \
              --no-progress \
              ${ENDPOINT_APPEND} $*" \
&& sh -c "aws s3 sync ${source} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --profile react-deploy-to-s3-action \
              --metadata-directive REPLACE \
              --cache-control max-age=86400 \
              --exclude index.html --exclude 'static/*' \
              --no-progress \
              ${ENDPOINT_APPEND} $*" \
&& sh -c "aws s3 sync ${source}/static s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --profile react-deploy-to-s3-action \
              --metadata-directive REPLACE \
              --cache-control max-age=31536000 \
              --exclude index.html --exclude 'static/*' \
              --no-progress \
              ${ENDPOINT_APPEND} $*" \

SUCCESS=$?

# Clear out credentials after we're done.
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there.
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile s3-sync-action <<-EOF > /dev/null 2>&1
null
null
null
text
EOF

if [ $SUCCESS -eq 0 ]
then
  echo "Deploy successful."
else
  echo "Failed to perform deploy!"
  exit 1
fi
