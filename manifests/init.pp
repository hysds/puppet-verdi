#####################################################
# verdi class
#####################################################

class verdi inherits hysds_base {

  #####################################################
  # copy user files
  #####################################################

  file { "/home/$user/.bash_profile":
    ensure  => present,
    content => template('verdi/bash_profile'),
    owner   => $user,
    group   => $group,
    mode    => 0644,
    require => File_line["user_source_anaconda"],
  }


  #####################################################
  # work directory
  #####################################################

  $work_dir = "/data/work"


  #####################################################
  # verdi directory
  #####################################################

  $verdi_dir = "/home/$user/verdi"


  #####################################################
  # install packages
  #####################################################

  package {
    'mailx': ensure => present;
    'httpd': ensure => present;
    'mod_ssl': ensure => present;
    'sysstat': ensure => present;
  }


  #####################################################
  # systemd daemon reload
  #####################################################

  exec { "daemon-reload":
    path        => ["/sbin", "/bin", "/usr/bin"],
    command     => "systemctl daemon-reload",
    refreshonly => true,
  }

  
  #####################################################
  # configure webdav for work directory
  #####################################################

  file { "$verdi_dir/src/beefed-autoindex-open_in_new_win.tbz2":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => 0644,
    source => 'puppet:///modules/verdi/beefed-autoindex-open_in_new_win.tbz2',
    require => [
        File["$verdi_dir/src"],
    ],
  }


  #####################################################
  # install install_hysds.sh script and other config
  # files in ops home
  #####################################################

  file { "/home/$user/install_hysds.sh":
    ensure  => present,
    content => template('verdi/install_hysds.sh'),
    owner   => $user,
    group   => $group,
    mode    => 0755,
    require => User[$user],
  }


  file { ["$work_dir",
          "$verdi_dir",
          "$verdi_dir/bin",
          "$verdi_dir/src",
          "$verdi_dir/etc"]:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => 0755,
    require => User[$user],
  }


  file { "$verdi_dir/bin/verdid":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => 0755,
    content => template('verdi/verdid'),
    require => File["$verdi_dir/bin"],
  }


  file { "$verdi_dir/bin/start_verdi":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => 0755,
    content => template('verdi/start_verdi'),
    require => File["$verdi_dir/bin"],
  }
 

  file { "$verdi_dir/bin/stop_verdi":
    ensure  => present,
    owner   => $user,
    group   => $group,
    mode    => 0755,
    content => template('verdi/stop_verdi'),
    require => File["$verdi_dir/bin"],
  }


  #####################################################
  # secure and configure httpd
  #####################################################

  file { "/etc/httpd/conf.d/autoindex.conf":
    ensure  => present,
    content => template('verdi/autoindex.conf'),
    mode    => 0644,
    require => Package['httpd'],
  }


  file { "/etc/httpd/conf.d/hysds_dav.conf":
    ensure  => present,
    content => template('verdi/hysds_dav.conf'),
    mode    => 0644,
    require => Package['httpd'],
  }


  file { "/etc/httpd/conf.d/welcome.conf":
    ensure  => present,
    content => template('verdi/welcome.conf'),
    mode    => 0644,
    require => Package['httpd'],
  }


  file { "/etc/httpd/conf.d/ssl.conf":
    ensure  => present,
    content => template('verdi/ssl.conf'),
    mode    => 0644,
    require => Package['httpd'],
  }


  file { '/var/www/html/index.html':
    ensure  => file,
    content  => template('verdi/index.html'),
    mode    => 0644,
    require => Package['httpd'],
  }


}
