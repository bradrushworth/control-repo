class role::puppet::master {
  include profile::base
  include profile::os::freebsd
  include profile::puppet::master
}
