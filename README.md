# docker-lambda-rust-builder

Docker build environment for Rust Runtime for AWS Lambda


## How to use

```
$ mkdir workspace && cd workspace
$ docker run -it --rm \
    -v "$(pwd):/build" \
    -w "/build" \
    -h "$(basename "$(pwd)")" \
    anyakichi/lambda-rust-builder
[builder@workspace build]$ extract
[builder@workspace build]$ setup
[builder@workspace build]$ build
[builder@workspace build]$ package
```

You can use the [din](https://github.com/anyakichi/docker-buildenv/blob/master/din.sh) wrapper script for simplicity.

```
$ mkdir workspace && cd workspace
$ din anyakichi/lambda-rust-builder
[builder@workspace build]$ extract
[builder@workspace build]$ setup
[builder@workspace build]$ build
[builder@workspace build]$ package
```

If you want to share cargo caches with host environment, add extra options.

```
$ din -e CARGO_HOME=/cargo -v $HOME/.cargo:/cargo anyakichi/lambda-rust-builder
[builder@workspace build]$ build
```


By default, sample lambda program
(https://github.com/anyakichi/lambda-rust-sample.git) is downloaded and
compiled, but you can override it:

```
$ din -e GIT_REPO=<your-repo> anyakichi/lambda-rust-builder
```

Or you can build your own Docker build environment with Dockerfile.

```
FROM anyakichi/lambda-rust-builder
ENV GIT_REPO=<your-repo>
```

## Sub commands

### extract

Download project repository using git clone.

### setup

Move to project repository.

### build

Build the binary.

### package

Create a zip file to upload to Lambda.

### run

Run the lambda function in Docker container.

If you use the run sub command, publish port 9001 to host environment.

```
$ din -p 9001:9001 anyakichi/lambda-rust-builder
[builder@workspace build]$ run
```

And access to this from host environment.

```
$ curl -d '{}' http://localhost:9001/2015-03-31/functions/myfunction/invocations
```

## Direct mode

You can execute sub commands directly from din command.

```
$ din -p 9001:9001 anyakichi/lambda-rust-builder run
```

## See also

https://github.com/anyakichi/docker-buildenv
