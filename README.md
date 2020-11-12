![React](https://assets.jeanlescure.io/eooifcELx.svg)
![arrow pointing right towards](https://assets.jeanlescure.io/eZA9H5.svg)
![S3 Bucket](https://assets.jeanlescure.io/bJ4s8H8n.svg)

# React Deploy to S3 Github Action

Build a React.js web app and sync to an AWS S3 repository

## Like this project? ❤️

Please consider:

- [Buying me a coffee](https://www.buymeacoffee.com/jeanlescure) ☕
- Supporting me on [Patreon](https://www.patreon.com/jeanlescure) 🏆
- Starring this repo on [Github](https://github.com/jeanlescure/react-deploy-to-s3-action) 🌟

## Usage

This action runs the equivalent of this oversimplified example:

```sh
$ yarn
$ yarn build
$ aws s3 sync public s3://your.website.com/
 # Optionally
$ aws cloudfront create-invalidation --distribution-id XYZ --paths /\*
```

With the previous in mind:

1- Make sure there is a `build` script in your `package.json`.
2- Place in your .github/workflows directory a `.yml` similar to the following:

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
    - uses: jeanlescure/react-deploy-to-s3-action@main
      with:
        args: --acl public-read --follow-symlinks --delete
      env:
        NODE_ENV: development # optional: defaults to production
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: us-west-1 # optional: defaults to us-east-1
        SOURCE_DIR: bundle # optional: defaults to public
```

### Configuration

The following settings must be passed as environment variables as shown in the example.
Sensitive information, especially `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, should be
[set as encrypted secrets](https://help.github.com/en/articles/virtual-environments-for-github-actions#creating-and-using-secrets-encrypted-variables) — otherwise, they'll be public to anyone browsing your repository's source code and CI logs.

| Key | Value | Suggested Type | Required | Default |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| `NODE_ENV` | This environment variable is commonly used by the web packager to select the appropriate variables for the environment you will deploy to | `env` | No | `production` |
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret env` | **Yes** | N/A |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key. [More info here.](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) | `secret env` | **Yes** | N/A |
| `AWS_S3_BUCKET` | The name of the bucket you're syncing to. For example, `jarv.is` or `my-app-releases`. | `secret env` | **Yes** | N/A |
| `AWS_REGION` | The region where you created your bucket. Set to `us-east-1` by default. [Full list of regions here.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions) | `env` | No | `us-east-1` |
| `AWS_S3_ENDPOINT` | The endpoint URL of the bucket you're syncing to. Can be used for [VPC scenarios](https://aws.amazon.com/blogs/aws/new-vpc-endpoint-for-amazon-s3/) or for non-AWS services using the S3 API, like [DigitalOcean Spaces](https://www.digitalocean.com/community/tools/adapting-an-existing-aws-s3-application-to-digitalocean-spaces). | `env` | No | Automatic (`s3.amazonaws.com` or AWS's region-specific equivalent) |
| `SOURCE_DIR` | The `yarn build` output directory you wish to sync/upload to S3. | `env` | No | `public` |
| `DEST_DIR` | The directory inside of the S3 bucket you wish to sync/upload to. For example, `my_project/assets`. Defaults to the root of the bucket. | `env` | No | `/` (root of bucket) |
| `CLOUDFRONT_DISTRIBUTION_ID` | If you include a CloudFront Distribution Id using this variable, the action will run `aws cloudfront create-invalidation` for the wildcard path `*`, meaning it will completely flush the cache (Note: AWS considers this a single invalidation even though it affects all files in the distribution) so that the new changes synced to S3 are available immediately. | `secret env` | No | N/A |

## TROUBLESHOOTING

- Errors such as `/bin/sh: react-scripts: not found` or `To import Sass files, you first need to install node-sass.` are usually caused by these or other libraries being within `devDependencies` in the `package.json`. **ALL** dependencies should be under the `dependencies` entry within `package.json`. A react application which gets pushed to S3 will be bundled with all its dependencies, there is no such thing as dependencies that are used for development vs production, all dependencies are needed to build the final package of html, js, css, etc.

## License

This project is distributed under the [Apache-2.0 license](LICENSE.md).
