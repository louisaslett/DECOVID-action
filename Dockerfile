FROM louisaslett/decovid-action-docker:v1

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
