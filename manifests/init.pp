# == Class: strongswan
#   Strongswan puppet module for Debian.
#   Configure strongswan, authorize IP forward, start service and add firewall rules to authorize IPsec packets. 
# === Parameters
#
# [*remote_public_ip*]
#   Public address of the remote vpn server
#   Default : undef
#
# [*host_public_ip*]
#   Public address of the local vpn server
#   Default : undef
#
# [*remote_private_network*]
#   Private network address of the remote vpn server
#   Netmask needed :
#   Example : 172.16.0.0/16
#   Default : undef
#
# [*host_private_network*]
#   Private network address of the local vpn server
#   Netmask needed : example : 192.168.56.0/24
#
# [*connection_name*]
#   Name of the connection
#   Default : myconn
#
# [*package*]
#   Package name to install
#   Default : system dependent (only Debian is supported)
#
# [*pass*]
#   Pre shared pass
#   Default : pass
#
# === Example
#
#   class { 'strongswan' :
#     remote_public_ip        => <public_IP_of_remote_VPN_server>,
#     host_public_ip          => <public_IP_of_local_server>,
#     remote_private_network  => <private_network_address_of_remote_VPN_server>,
#     host_private_network    => <private_network_address_of_local_server>,
#   }
#
# === Authors
#
# Thibault Marquand <thibault.marquand@utt.fr>
#
# === Copyright
#
# Copyright 2014 ECHOES Technologies <contact@echoes-tech.com> 
#
class strongswan 
(
  $remote_public_ip         = $strongswan::params::remote_public_ip,
  $host_public_ip           = $strongswan::params::host_public_ip,
  $remote_private_network   = $strongswan::params::remote_private_network,
  $host_private_network     = $strongswan::params::host_private_network,
  $connection_name          = 'myconn',
  $package                  = $strongswan::params::package,
  $pass                     = 'pass',
) inherits strongswan::params

{
include 'strongswan::firewall'

package { $package :
  ensure    => 'present',
  name      => 'strongswan',
  before    => Service['strongswan'],
  }

file { '/etc/ipsec.conf':
  ensure    => 'file',
  owner     => 'root',
  group     => 'root',
  mode      => '0644',
  content   =>  template('strongswan/ipsec.conf.erb'),
  }

file { '/etc/ipsec.secrets':
  ensure    => 'present',
  owner     => 'root',
  group     => 'root',
  mode      => '0640',
  content   => template('strongswan/ipsec.secrets.erb'),
  }

service { 'strongswan':
  ensure    => 'running',
  name      => 'ipsec',
  enable    => true,
  subscribe => File['/etc/ipsec.conf'],
  }
}
