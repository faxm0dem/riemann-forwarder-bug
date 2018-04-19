# README

## Build

```
puppet docker dockerfile --image-name riemann-fw-bug/riemann_branch --entrypoint /usr/local/bin/dumb-init,-- --expose 5555:5555 --cmd riemann > Dockerfile-riemann_branch
puppet docker dockerfile --image-name riemann-fw-bug/riemann_leaf --entrypoint /usr/local/bin/dumb-init,-- --expose 5555:5555,5556:5556 --cmd riemann > Dockerfile-riemann_leaf
puppet docker dockerfile --image-name riemann-fw-bug/collectd_tg --entrypoint /usr/local/bin/dumb-init,-- --expose 5556:5556 --cmd 'collectd-tg,-d localhost' > Dockerfile-collectd_tg
```

## Run

```
docker-compose up
```

