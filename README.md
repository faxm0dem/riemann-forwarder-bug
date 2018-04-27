# README

## Build

```
rake build:compose
```

or manually:

```
puppet docker dockerfile --image-name riemann-fw-bug/riemann_branch > Dockerfile-riemann_branch
puppet docker dockerfile --image-name riemann-fw-bug/riemann_leaf   > Dockerfile-riemann_leaf
puppet docker dockerfile --image-name riemann-fw-bug/collectd_fw    > Dockerfile-collectd_fw
puppet docker dockerfile --image-name riemann-fw-bug/collectd_tg    > Dockerfile-collectd_tg
docker-compose build
```

## Run

```
rake run
```

or manually:

```
docker-compose up
```

## Use

```
# subscribe to syslog events
wsdump.py -r 'ws://127.0.0.1:32772/index?subscribe=true&query=tagged+"syslog"'
# subscribe to collectd events
wsdump.py -r 'ws://127.0.0.1:32772/index?subscribe=true&query=tagged+"collectd"'
```
