FROM jeanlescure/node-awscli:latest

LABEL "com.github.actions.name"="React Deploy to S3"
LABEL "com.github.actions.description"="Build a React.js web app and sync to an AWS S3 repository"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="green"

LABEL version="1.1.0"
LABEL repository="https://github.com/jeanlescure/react-deploy-to-s3-action"
LABEL homepage="https://jeanlescure.io/"
LABEL maintainer="Jean Lescure <opensource@jeanlescure.io>"

ENV PATH /github/workspace/node_modules/.bin:$PATH
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
