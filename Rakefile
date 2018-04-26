#
task default: %w[run]

NODES=%W[riemann_branch riemann_leaf collectd_fw collectd_tg syslog_ng_fw syslog_ng_loggen]

namespace 'build' do
  task :dockerfiles do
    NODES.each do |n|
      sh("puppet docker dockerfile --image-name riemann-fw-bug/#{n} > Dockerfile-#{n}")
    end
  end

  task :compose => ['dockerfiles'] do
    sh("docker-compose build")
  end
end

task :run do
  sh('docker-compose up')
end
