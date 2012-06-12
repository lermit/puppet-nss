# = Define: nss::directive
#
#   This ressource type define an entry into /etc/nsswitch.conf
#   file. For example you can add ldap for group database into
#   /etc/nsswitch.conf and ensure file isn't present.
#
# == Parameters
#
# [*ensure*]
#   Define if the directive should be present (default) or 'absent'
#
# [*database*]
#   Database to used (Like passwd, group, shawdow).
#   man nsswitch.conf provide a full list of avariable database.
#
# [*service*]
#   Service to add to database.
#
define nss::directive (
  $database,
  $service,
  $ensure  = present
) {

  include nss

  if $ensure == absent {
    exec { "nss_${database}_${service}":
      command => "sed 's/^\(${database}:.*\)${service}\(.*\)$/\1\2/g' ${nss::params::config_file}",
      onlyif  => "grep '${database}' ${nss::params::config_file} | grep '${service}'",
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    }
  } else {
    exec { "nss_${database}_${service}":
      command => "sed -i 's/${database}:\(.*\)/${database}:\1 ${service}/g' ${nss::params::config_file}",
      unless  => "grep '${database}' ${nss::params::config_file} | grep '${service}'",
      path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    }
  }

}
