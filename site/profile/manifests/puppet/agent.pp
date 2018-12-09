class profile::puppet::agent (
) {

#  class { '::puppet':
#    runmode => 'cron',
#  }

  class { 'puppetagent':
    env            => 'production',
    master         => 'puppet.bitbot.net.au',
    onboot         => true,
    service_enable => false,
    service_ensure => 'stopped',
  }

  class { '::puppetagent::cron':
    ensure     => 'present',
    report     => 'errors',
    email      => 'bitbot@bitbot.com.au',
    hour       => 5,
    minute     => 50,
    splaylimit => '30m',
  }

}

