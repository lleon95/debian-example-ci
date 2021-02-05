# MIT License
# Luis G. Leon Vega - 2021

FROM alpine:3.10

LABEL "com.github.actions.name"="Debian Changelog CI"
LABEL "com.github.actions.description"="This is an action that commits on a release pull request with the changelog"
LABEL "com.github.actions.icon"="clock"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/lleon95/debian-changelog"
LABEL "homepage"="https://github.com/lleon95/debian-changelog"
LABEL "maintainer"="lleon95"

RUN apk update && apk add bash git

COPY ./scripts/changelog-ci.sh /changelog-ci.sh

RUN ["chmod", "+x", "/changelog-ci.sh"]
ENTRYPOINT ["bash", "/changelog-ci.sh"]
