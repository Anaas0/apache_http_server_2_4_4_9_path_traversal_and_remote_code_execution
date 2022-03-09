# Class: apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution::service
#
#
class apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution::service {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  # resources

  # Move service file to correct location.
  file { '/etc/systemd/system/httpd.service':
    ensure  => present,
    source  => 'puppet:///modules/apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution/httpd.service',
    owner   => 'root',
    mode    => '0777', # Full permissions.
    require => Exec['/usr/local/apache2/conf/httpd.conf'],
    notify  => Exec['start-httpd'],
  }

  # Start httpd
  exec { 'start-httpd':
    command => 'sudo ./httpd',
    cwd     => '/usr/local/apache2/bin/',
    require => File['/etc/systemd/system/httpd.service'],
    notify  => Cron['start-httpd-cron'],
  }

  cron { 'start-httpd-cron':
    command => 'sudo /usr/local/apache2/bin/httpd',
    special => 'reboot',
    require => Exec['start-httpd'],
    notify  => Service['httpd'],
  }

  service { 'httpd':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/systemd/system/httpd.service'],
  }
}
