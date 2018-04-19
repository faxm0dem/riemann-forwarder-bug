class site_common {
  package {'python-pip':
    ensure => 'latest'
  }
  ~> package {'dumb-init':
    ensure   => 'latest',
    provider => 'pip',
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
}

class site_riemann::role::branch {
  Service {
    provider => dummy
  }

  class { 'site_riemann': }
  riemann::stream { 'forward to leaf':
    content => @("EOF")
      (batch 1000 10
        (exception-stream
          (throttle 1 10 (with {:host our-host :service "forward-leaf" :state "warning"} (adjust [:event #(count %)] #(info %))))
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
  riemann::let { 'index':
    content => 'index (default {:state "ok" :ttl 60} (index))'
  }
  riemann::stream {'index':}
}

class site_collectd {
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
  include ::site_collectd
}
