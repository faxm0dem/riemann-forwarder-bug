# README

## Build

```
puppet docker dockerfile --image-name riemann-fw-bug/riemann_branch > Dockerfile-riemann_branch
puppet docker dockerfile --image-name riemann-fw-bug/riemann_leaf   > Dockerfile-riemann_leaf
puppet docker dockerfile --image-name riemann-fw-bug/collectd_fw    > Dockerfile-collectd_fw
puppet docker dockerfile --image-name riemann-fw-bug/collectd_tg    > Dockerfile-collectd_tg
```

## Run

```
docker-compose up
```

