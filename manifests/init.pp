#####################################################
# verdi class
#####################################################

class verdi inherits scientific_python {

  #####################################################
  # add swap file 
  #####################################################

  #swap { '/mnt/swapfile':
  #  ensure   => present,
  #}


  #####################################################
  # copy user files
  #####################################################

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

  $jdk_rpm_file = "jdk-8u241-linux-x64.rpm"
  $jdk_rpm_path = "/etc/puppet/modules/verdi/files/$jdk_rpm_file"
  $jdk_pkg_name = "jdk1.8.x86_64"
  $java_bin_path = "/usr/java/jdk1.8.0_241-amd64/jre/bin/java"


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
  # secure and start httpd
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


  service { 'httpd':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => [
                   File['/etc/httpd/conf.d/autoindex.conf'],
                   File['/etc/httpd/conf.d/hysds_dav.conf'],
                   File['/etc/httpd/conf.d/welcome.conf'],
                   File['/etc/httpd/conf.d/ssl.conf'],
                   File['/var/www/html/index.html'],
                   Exec['daemon-reload'],
                  ],
  }


  #####################################################
  # firewalld config
  #####################################################

  firewalld::zone { 'public':
    services => [ "ssh", "dhcpv6-client", "http", "https" ],
    ports => [
      {
        # work_dir dav server
        port     => "8085",
        protocol => "tcp",
      },
      {
        # work_dir tsunamid (tcp)
        port     => "46224",
        protocol => "tcp",
      },
      {
        # work_dir tsunamid (udp)
        port     => "46224",
        protocol => "udp",
      },
    ]
  }


  #firewalld::service { 'dummy':
  #  description	=> 'My dummy service',
  #  ports       => [{port => '1234', protocol => 'tcp',},],
  #  modules     => ['some_module_to_load'],
  #  destination	=> {ipv4 => '224.0.0.251', ipv6 => 'ff02::fb'},
  #}


}
