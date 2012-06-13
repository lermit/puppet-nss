# Class: nss::params
#
# This class defines default parameters used by the main module class nss
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to nss class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class nss::params {

  ### Application related parameters

  $config_file = $::operatingsystem ? {
    default => '/etc/nsswitch.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  # General Settings
  $my_class = ''
  $source = ''
  $template = ''
  $options = ''

  ### General module variables that can have a site or per module default
  $debug = false
  $audit_only = false

}
