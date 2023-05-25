# React Deploy to S3 Github Action

Sync a built React application to an AWS S3 repository.

## Usage

This action runs the equivalent of this oversimplified example:

```sh
$ aws s3 sync build s3://your.website.com/
```

But it sets sensible cache headers so that re-deploys cause changes to get picked up.

- /index.html - Cachable for 5 seconds. This is so we never hit the S3 bucket hard under high load (unlikely).
- /static/* - Cachable forever.
- /* - Cachable for a day.

With the previous in mind:

 1 - Place in your .github/workflows directory a `.yml` similar to the following:

```yml
name: Upload Website

on:
  push:
    branches:
    - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@main
    - uses: oxctl/react-deploy-to-s3-action@main
      with:
        args: --acl public-read --follow-symlinks --delete
      env:
        NODE_ENV: development # optional: defaults to production
        AWS_S3_BUCKET: ${{ variables.AWS_S3_BUCKET }}
        AWS_ACCESS_KEY_ID: ${{ variables.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: eu-west-1 # optional: defaults to us-east-1
        SOURCE_DIR: bundle # optional: defaults to public
```

### Configuration

The following settings must be passed as environment variables as shown in the example.
Sensitive information, especially `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, should be
[set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) — otherwise, they'll be public to anyone browsing your repository's source code and CI logs.

| Key | Value | Suggested Type | Required | Default                                                            |
| ------------- | ------------- |----------------| ------------- |--------------------------------------------------------------------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `variable env` | **Yes** | N/A                                                                |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret env`   | **Yes** | N/A                                                                |
| `AWS_S3_BUCKET` | The name of the bucket you're syncing to. For example, `jarv.is` or `my-app-releases`. | `variable env` | **Yes** | N/A                                                                |
| `AWS_REGION` | The region where you created your bucket. Set to `us-east-1` by default. [Full list of regions here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env`          | No | `us-east-1`                                                        |
| `AWS_S3_ENDPOINT` | The endpoint URL of the bucket you're syncing to. Can be used for [VPC scenarios](https://aws.amazon.com/blogs/aws/new-vpc-endpoint-for-amazon-s3/) or for non-AWS services using the S3 API, like [DigitalOcean Spaces](https://www.digitalocean.com/community/tools/adapting-an-existing-aws-s3-application-to-digitalocean-spaces). | `env`          | No | Automatic (`s3.amazonaws.com` or AWS's region-specific equivalent) |
| `SOURCE_DIR` | The build output directory you wish to sync/upload to S3. | `env`          | No | `build`                                                            |
| `DEST_DIR` | The directory inside of the S3 bucket you wish to sync/upload to. For example, `my_project/assets`. Defaults to the root of the bucket. | `env`          | No | `/` (root of bucket)                                               |

## TROUBLESHOOTING

## License

This project is distributed under the [Apache-2.0 license](LICENSE.md).
