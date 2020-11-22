```
$ . <(buildenv setup)
$ DOCKER_LAMBDA_STAY_OPEN=1 /var/runtime/init -bootstrap "target/release/$(basename -s .git "${GIT_REPO}")"
```
