```
$ [[ "\$(basename \$(pwd))" == "$(basename -s .git "${GIT_REPO}")" ]] || cd $(basename -s .git "${GIT_REPO}")
```
