FROM docker.pkg.github.com/louisaslett/decovid-action/decovid-action-docker:v1

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
