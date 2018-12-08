class profile::base {

  #the base profile should include component modules that will be on all nodes

  file { '/etc/motd':
    ensure  => file,
    owner   => 'root',
    group   => 'wheel',
    mode    => '644',
    content => "This is my special ${facts['fqdn']} with message: ${message}\n\nThis node is managed by Puppet, changes may be overwritten.\n",
  }

}
