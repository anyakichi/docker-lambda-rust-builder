# docker-lambda-rust-builder

[docker-buildenv](https://github.com/anyakichi/docker-buildenv) for Rust
Runtime on AWS Lambda.

## How to use

```
$ mkdir workspace && cd $_
$ din anyakichi/lambda-rust-builder
[builder@workspace build]$ extract
[builder@workspace build]$ setup
[builder@workspace lambda-rust-sample]$ build
[builder@workspace lambda-rust-sample]$ package
```

If you want to share cargo caches with the host environment, add extra options.

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

### deploy

Deploy a zip file to Lambda.

### run

Run the lambda function in Docker container.

When you use the run sub command, publish port 8080 to the host environment.

```
$ din -p 8080:8080 anyakichi/lambda-rust-builder
[builder@workspace build]$ run
```

And access to this from the host environment.

```
$ curl -d '{}' http://localhost:8080/2015-03-31/functions/function/invocations
```

### (other commands)

And you can execute anything in the container.

Build debug binary:

```
[builder@workspace lambda-rust-sample]$ cargo build
```

## Direct mode

You can execute sub commands directly from din command.

```
$ din -p 8080:8080 anyakichi/lambda-rust-builder run
```
