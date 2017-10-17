#####################################################
# verdi class
#####################################################

class verdi {

  #####################################################
  # create groups and users
  #####################################################
  
  #notify { $user: }
  if $user == undef {

    $user = 'ops'
    $group = 'ops'

    group { $group:
      ensure     => present,
    }
  

    user { $user:
      ensure     => present,
      gid        =>  $group,
      shell      => '/bin/bash',
      home       => "/home/$user",
      managehome => true,
      require    => Group[$group],
    }


    file { "/home/$user":
      ensure  => directory,
      owner   => $user,
      group   => $group,
      mode    => 0755,
      require => User[$user],
    }


    inputrc { 'root':
      home    => '/root',
    }


    inputrc { $user:
      home    => "/home/$user",
      require => User[$user],
    }


  }


  file { "/home/$user/.git_oauth_token":
    ensure  => file,
    content  => template('verdi/git_oauth_token'),
    owner   => $user,
    group   => $group,
    mode    => 0600,
    require => [
                User[$user],
               ],
  }


  file { "/home/$user/.bash_profile":
    ensure  => present,
    content => template('verdi/bash_profile'),
    owner   => $user,
    group   => $group,
    mode    => 0644,
    require => User[$user],
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
    'httpd-devel': ensure => present;
    'mod_ssl': ensure => present;
    'sysstat': ensure => present;
    'libsysstat-devel': ensure => present;
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
  # install oracle java and set default
  #####################################################

  $jdk_rpm_file = "jdk-8u60-linux-x64.rpm"
  $jdk_rpm_path = "/etc/puppet/modules/verdi/files/$jdk_rpm_file"
  $jdk_pkg_name = "jdk1.8.0_60"
  $java_bin_path = "/usr/java/$jdk_pkg_name/jre/bin/java"


  cat_split_file { "$jdk_rpm_file":
    install_dir => "/etc/puppet/modules/verdi/files",
    owner       =>  $user,
    group       =>  $group,
  }


  package { "$jdk_pkg_name":
    provider => rpm,
    ensure   => present,
    source   => $jdk_rpm_path,
    notify   => Exec['ldconfig'],
    require     => Cat_split_file["$jdk_rpm_file"],
  }


  update_alternatives { 'java':
    path     => $java_bin_path,
    require  => [
                 Package[$jdk_pkg_name],
                 Exec['ldconfig']
                ],
  }


  #####################################################
  # get integer memory size in MB
  #####################################################

  if '.' in $::memorysize_mb {
    $ms = split("$::memorysize_mb", '[.]')
    $msize_mb = $ms[0]
  }
  else {
    $msize_mb = $::memorysize_mb
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


  file { '/var/www/html/index.html':
    ensure  => file,
    content  => template('verdi/index.html'),
    mode    => 0644,
    require => Package['httpd'],
  }


}
