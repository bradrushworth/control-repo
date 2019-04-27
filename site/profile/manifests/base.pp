class profile::base(
) {

  service { 'sshd':
    ensure => running,
    enable => true,
  }

}
