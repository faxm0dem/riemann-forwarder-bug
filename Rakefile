#
task default: %w[run]

NODES=%W[riemann_branch riemann_leaf collectd_fw collectd_tg syslog_ng_fw syslog_ng_loggen]

NODES.each do |n|
  desc "generate dockerfile for #{n}"
  file "Dockerfile-#{n}" => ['manifests/init.pp', 'metadata/metadata.yaml', "metadata/#{n}.yaml"] do
    sh("puppet docker dockerfile --image-name riemann-fw-bug/#{n} > Dockerfile-#{n}")
  end
end

namespace :build do
  NODES.each do |n|
    desc "generate docker container for #{n}"
    task "#{n}" => "Dockerfile-#{n}" do
      sh("docker build -t riemann-fw-bug/#{n} -f Dockerfile-#{n} .")
    end
  end
  desc 'build docker containers'
  task :compose => NODES.map { |n| "Dockerfile-#{n}" } do
    sh("docker-compose build")
  end
end

desc 'run docker containers'
task :run => 'build:compose' do
  sh('docker-compose up')
end

