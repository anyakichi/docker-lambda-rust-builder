```
$ . <(buildenv setup)
$ cp "target/release/$(basename -s .git "${GIT_REPO}")" /tmp/bootstrap
$ zip -mj $(basename -s .git "${GIT_REPO}").zip /tmp/bootstrap
```
