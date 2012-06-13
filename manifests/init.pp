# = Class: nss
#
# This is the main nss class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, nss class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $nss_myclass
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, nss main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $nss_source
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, nss main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $nss_template
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $nss_options
#
# [*puppi*]
#   Set to 'true' to enable creation of module data files that are used by puppi
#   Can be defined also by the (top scope) variables $nss_puppi and $puppi
#
# [*puppi_helper*]
#   Specify the helper to use for puppi commands. The default for this module
#   is specified in params.pp and is generally a good choice.
#   You can customize the output of puppi commands for this module using another
#   puppi helper. Use the define puppi::helper to create a new custom helper
#   Can be defined also by the (top scope) variables $nss_puppi_helper
#   and $puppi_helper
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#   Can be defined also by the (top scope) variables $nss_debug and $debug
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $nss_audit_only
#   and $audit_only
#
# Default class params - As defined in nss::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*config_file*]
#   Main configuration file path
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# == Examples
#
# You can use this class in 2 ways:
# - Set variables (at top scope level on in a ENC) and "include nss"
# - Call nss as a parametrized class
#
# See README for details.
#
#
# == Author
#   Romain THERRAT <romain42@gmail.com/>
#
class nss (
  $my_class            = params_lookup( 'my_class' ),
  $source              = params_lookup( 'source' ),
  $template            = params_lookup( 'template' ),
  $options             = params_lookup( 'options' ),
  $config_file         = params_lookup( 'config_file' ),
  $config_file_mode    = params_lookup( 'config_file_mode' ),
  $config_file_owner   = params_lookup( 'config_file_owner' ),
  $config_file_group   = params_lookup( 'config_file_group' ),
  $audit_only          = params_lookup( 'audit_only' , 'global' )
  ) inherits nss::params {

  $bool_audit_only=any2bool($audit_only)

  $manage_file_source = $nss::source ? {
    ''        => undef,
    default   => $nss::source,
  }

  $manage_file_content = $nss::template ? {
    ''        => undef,
    default   => template($nss::template),
  }

  $manage_audit = $nss::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_file_replace = $nss::bool_audit_only ? {
    true  => false,
    false => true,
  }

  ### Managed resources
  file { 'nss.conf':
    ensure  => $nss::manage_file,
    path    => $nss::config_file,
    mode    => $nss::config_file_mode,
    owner   => $nss::config_file_owner,
    group   => $nss::config_file_group,
    source  => $nss::manage_file_source,
    content => $nss::manage_file_content,
    replace => $nss::manage_file_replace,
    audit   => $nss::manage_audit,
  }

  ### Include custom class if $my_class is set
  if $nss::my_class {
    include $nss::my_class
  }

  ### Provide puppi data, if enabled ( puppi => true )
  if $nss::bool_puppi == true {
    $classvars=get_class_args()
    puppi::ze { 'nss':
      ensure    => $nss::manage_file,
      variables => $classvars,
      helper    => $nss::puppi_helper,
    }
  }

  ### Debugging, if enabled ( debug => true )
  if $nss::bool_debug == true {
    file { 'debug_nss':
      ensure  => $nss::manage_file,
      path    => "${settings::vardir}/debug-nss",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
    }
  }

}
