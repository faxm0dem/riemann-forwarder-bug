# README

## Build

```
puppet docker dockerfile --image-name riemann-fw-bug/riemann_branch --entrypoint /usr/local/bin/dumb-init,-- --expose 5555:5555 --cmd riemann > Dockerfile-riemann_branch
puppet docker dockerfile --image-name riemann-fw-bug/riemann_leaf --entrypoint /usr/local/bin/dumb-init,-- --expose 5555:5555,5556:5556 --cmd riemann > Dockerfile-riemann_leaf
puppet docker dockerfile --image-name riemann-fw-bug/collectd_fw --entrypoint /usr/local/bin/dumb-init,-- --expose 25826:25826 --cmd collectd,-f,-C,/etc/collectd.d/collectd.conf > Dockerfile-collectd_fw
puppet docker dockerfile --image-name riemann-fw-bug/collectd_tg --entrypoint /usr/local/bin/dumb-init,-- --cmd 'collectd-tg,-d collectd_fw' > Dockerfile-collectd_tg
```

## Run

```
docker-compose up
```

