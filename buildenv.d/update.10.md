```
$ . <(buildenv setup)
$ aws lambda update-function-code \
    --function-name ${FUNCTION_NAME:-$(basename -s .git "${GIT_REPO}")} \
    --zip-file fileb://$(basename -s .git "${GIT_REPO}").zip
```
