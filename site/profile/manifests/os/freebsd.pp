class profile::os::freebsd(
) {

  file { '/etc/motd':
    ensure  => file,
    owner   => 'root',
    group   => 'wheel',
    mode    => '644',
    content => "This is server ${facts['fqdn']}\n\nThis node is managed by Puppet, changes may be overwritten.\n",
  }


}
