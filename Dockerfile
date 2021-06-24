# Create a base layer with linkerd-await from a recent release.
FROM curlimages/curl:7.77.0 as linkerd
ARG LINKERD_AWAIT_VERSION=v0.2.3
RUN curl -sSLo /tmp/linkerd-await https://github.com/linkerd/linkerd-await/releases/download/release%2F${LINKERD_AWAIT_VERSION}/linkerd-await-${LINKERD_AWAIT_VERSION}-amd64 && \
    chmod 755 /tmp/linkerd-await

# Build your application with whatever environment makes sense.
FROM myapp-build as app
WORKDIR /app
RUN make build

# Package the application wrapped by linkerd-await. Note that the binary is
# static so it can be used in `scratch` images:
FROM scratch
COPY --from=linkerd /tmp/linkerd-await /linkerd-await
COPY --from=app /app/myapp /myapp
# In this case, we configure the proxy to be shutdown after `myapp` completes
# running. This is only really needed for jobs where the application is
# expected to complete on its own (namely, `Jobs` and `Cronjobs`)
ENTRYPOINT ["/linkerd-await", "--shutdown", "--"]
CMD  ["/myapp"]
