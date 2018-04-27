class site_common {
  package {'python-pip':
    ensure => 'latest'
  }
  -> package {'dumb-init':
    ensure   => 'latest',
    provider => 'pip',
  }
}

class site_syslog_ng::role::fw {
  class { 'syslog_ng':
    modules => [ 'riemann' ]
  }
  syslog_ng::source { 's_system':
    params => {
      'network' => [
        { 'ip_protocol' => 6 },
        { 'transport'   => 'udp' },
        { 'tags'        => [ "'syslog'" ] },
        { 'flags'       => [ 'syslog-protocol' ] },
      ]
    }
  }
  syslog_ng::config { 'version':
    content => "@version: 3.5",
    order   => '02',
  }
  syslog_ng::config { 'scl':
    content => '@include scl.conf',
    order   => '03',
  }
  syslog_ng::destination { 'd_riemann':
    params => {
      'riemann' => [
        { 'server'      => 'riemann_branch' },
        { 'port'        => 5555 },
        { 'type'        => 'tcp' },
        { 'description' => '"${MSG}"' },
        { 'attributes'  =>
          [
            { 'scope' => 'all-nv-pairs' },
          ]
        }
      ]
    }
  }
  syslog_ng::log { 'l_main':
    params => [
      { 'source'      => 's_system' },
      { 'destination' => 'd_riemann' },
    ]
  }
}

class site_syslog_ng::role::loggen {
  include syslog_ng
  file {'/loggen-loop':
    content => 'while loggen $@; do sleep 1; done',
    mode    => '0755'
  }
}

class site_riemann {
  wget::fetch { 'download riemann':
    source =>  'https://github.com/riemann/riemann/releases/download/0.3.0/riemann_0.3.0_all.deb',
    destination =>  '/tmp/riemann.deb',
    timeout =>  0,
    verbose =>  false,
  }
  -> Package <| title == 'riemann' |> {
    provider => 'dpkg',
    source   => '/tmp/riemann.deb',
  }
  package { 'openjdk-8-jre-headless': }
  -> class { 'riemann': }
  riemann::listen { 'tcp':
    options => {
      'port' => '5555',
      'host' => '"0.0.0.0"'
    }
  }
  riemann::listen { 'ws':
    options => {
      'port' => '5556',
      'host' => '"0.0.0.0"'
    }
  }
  riemann::let { 'index':
    content => 'index (default {:state "ok" :ttl 60} (index))'
  }
}

class site_riemann::role::branch {
  Service {
    provider => dummy
  }

  include ::site_riemann
  riemann::stream { 'index instrumentation':
    content => '(tagged "riemann" index)'
  }
  riemann::stream { 'forward to leaf':
    content => @("EOF")
        (exception-stream
          (throttle 1 10 (with {:host our-host :service "forward-leaf" :state "warning"} (adjust [:event #(count %)] #(info %))))
          (batch 1000 10
            (async-queue! :forward-leaf {:core-pool-size 16 :max-pool-size 32 :queue-size 1000}
              (forward (tcp-client :host "riemann_leaf")))))
      |- EOF
  }
}

class site_riemann::role::leaf {
  Service {
    provider => dummy
  }

  include ::site_riemann
  riemann::stream {'index':}
}

class site_collectd::tg {
  include ::collectd
}

class site_collectd::fw {
  include ::collectd
  collectd::config::plugin {'write_riemann':
    plugin   => 'write_riemann',
    settings => '<Node "branch">
                   Host "riemann_branch"
                   Port "5555"
                   Protocol "TCP"
                   StoreRates true
                   Ttlfactor 4.0
                   AlwaysAppendDs false
                   CheckThresholds true
                 </Node>
                 Tag "collectd"'
  }
  collectd::config::plugin {'network':
    plugin   => 'network',
    settings => 'Listen "0.0.0.0" "25826"'
  }
}

node 'riemann_branch' {
  include ::site_common
  include ::site_riemann::role::branch
}

node 'riemann_leaf' {
  include ::site_common
  include ::site_riemann::role::leaf
}

node 'collectd_tg' {
  include ::site_common
  include ::site_collectd::tg
}

node 'collectd_fw' {
  include ::site_common
  include ::site_collectd::fw
}

node 'syslog_ng_fw' {
  include ::site_common
  include ::site_syslog_ng::role::fw
}

node 'syslog_ng_loggen' {
  include ::site_common
  include ::site_syslog_ng::role::loggen
}
