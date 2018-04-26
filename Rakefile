#
task default: %w[run]

NODES=%W[riemann_branch riemann_leaf collectd_fw collectd_tg syslog_ng_fw syslog_ng_loggen]

namespace :build do
  NODES.each do |n|
    desc "generate dockerfile for #{n}"
    task n.to_sym do
      sh("puppet docker dockerfile --image-name riemann-fw-bug/#{n} > Dockerfile-#{n}")
    end
  end

  #desc 'build docker containers'
  #task :compose => ['dockerfiles'] do
  #  sh("docker-compose build")
  #end
end

desc 'generate all dockerfiles'
task :build do
  NODES.each do |n|
    Rake::Task["build:#{n}"].execute
  end
end

desc 'run docker containers'
task :run do
  sh('docker-compose up')
end
