class role::jenkins::master {
  include profile::base
  include profile::puppet::agent
  include profile::jenkins::master
}
