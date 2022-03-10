# Class: apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution::config
#
#
class apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution::config {
  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  # resources
  $user = 'websvr' #SecGen parameter.
  $user_home = "/home/${user}"

  # Create user.
  user { $user:
    ensure     => 'present',
    uid        => '666',
    gid        => 'root',#
    home       => $user_home,
    password   => 'Password123',
    managehome => true,
    require    => Package['pcre2-utils'],
    notify     => File['/opt/Apache_2.4.49/'],
  }

  # Remove current config
  exec { 'remove-config':
    command => 'sudo rm -f /usr/local/apache2/conf/httpd.conf',
    require => Exec['make-install'],
    notify  => Exec['remove-default-index'],
  }
  # Remove default index.html
  exec { 'remove-default-index':
    command => 'sudo rm -f /usr/local/apache2/htdocs/index.html',
    require => Exec['remove-config'],
    notify  => File['/usr/local/apache2/htdocs/index.html'],
  }

  # Possibly add a more interesting webpage. /usr/local/apache2/htdocs
  file { '/usr/local/apache2/htdocs/index.html':
    mode    => '0755',
    owner   => $user,
    source  => 'puppet:///modules/apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution/index.html',
    require => Exec['remove-default-index'],
    notify  => File['/usr/local/apache2/conf/httpd.conf'],
  }

  # Copy httpd.conf to /usr/local/apache2/conf/httpd.conf
  file { '/usr/local/apache2/conf/httpd.conf':
    mode    => '0755',
    owner   => $user,
    source  => 'puppet:///modules/apache_http_server_2_4_4_9_path_traversal_and_remote_code_execution/httpd.conf',
    require => File['/usr/local/apache2/htdocs/index.html'],
    notify  => File['/etc/systemd/system/httpd.service'],
  }
}
