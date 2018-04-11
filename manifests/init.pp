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
            (forward (tcp-client :host "riemann-leaf")))))
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

class site_collectd {
  include ::collectd
}

node 'riemann-branch1' {
  include ::site_riemann::role::branch
}

node 'riemann-branch2' {
  include ::site_riemann::role::branch
}

node 'riemann-leaf' {
  include ::site_riemann::role::leaf
}

node 'collectd-tg' {
  include ::site_collectd
}
