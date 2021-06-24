# Create a base layer with linkerd-await from a recent release.
FROM curlimages/curl:7.77.0 as linkerd
ARG LINKERD_AWAIT_VERSION=v0.2.3

RUN curl -sSLo /tmp/linkerd-await https://github.com/linkerd/linkerd-await/releases/download/release%2F${LINKERD_AWAIT_VERSION}/linkerd-await-${LINKERD_AWAIT_VERSION}-amd64 && \
    chmod 755 /tmp/linkerd-await

FROM alpine:3.13
RUN apk add --no-cache postgresql-client

COPY --from=linkerd /tmp/linkerd-await /linkerd-await
# COPY --from=linkerd /app/myapp /myapp
# In this case, we configure the proxy to be shutdown after `myapp` completes
# running. This is only really needed for jobs where the application is
# expected to complete on its own (namely, `Jobs` and `Cronjobs`)
ENTRYPOINT ["/linkerd-await", "psql", "--shutdown", "--"]
# CMD  ["/myapp"]
