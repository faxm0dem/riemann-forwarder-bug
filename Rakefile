#
task default: %w[run]

task :build do
  sh('puppet docker dockerfile --image-name riemann-fw-bug/riemann_branch > Dockerfile-riemann_branch')
  sh('puppet docker dockerfile --image-name riemann-fw-bug/riemann_leaf > Dockerfile-riemann_leaf')
  sh('puppet docker dockerfile --image-name riemann-fw-bug/collectd_fw > Dockerfile-collectd_fw')
  sh('puppet docker dockerfile --image-name riemann-fw-bug/collectd_tg > Dockerfile-collectd_tg')
  sh('docker-compose build')
end

task :run do
  sh('docker-compose up')
end
