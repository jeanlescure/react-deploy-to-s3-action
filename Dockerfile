FROM amazon/aws-cli:2.11.22

LABEL "com.github.actions.name"="React Deploy to S3"
LABEL "com.github.actions.description"="Sync a built React application to an AWS S3 repository"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="green"

LABEL version="1.1.0"
LABEL repository="https://github.com/oxctl/react-deploy-to-s3-action"
LABEL homepage="https://github.com/oxctl/react-deploy-to-s3-action"
LABEL maintainer="Jean Lescure <opensource@jeanlescure.io>"

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
