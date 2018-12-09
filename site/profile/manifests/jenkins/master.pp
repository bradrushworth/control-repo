class profile::jenkins::master (
  String $java_dist    = 'jdk',
  String $java_version = 'latest',
  String $known_hosts  = lookup('ssh::known_hosts'),
  String $jenkins_ssh_public,
  String $jenkins_ssh_private,
  String $jenkins_brad_password,
  String $redmine_brad_password,
) {

  File {
    owner        => 'jenkins',
    group        => 'jenkins',
    mode         => '664',
  }

  class { '::ruby':
    gems_version => 'latest',
  }

  class { 'java':
    distribution => $java_dist,
    version      => $java_version,
    before       => Class['jenkins'],
  }

  class { 'android':
    user         => 'jenkins',
    group        => 'jenkins',
    installdir   => '/usr/local/android',
  }
  android::platform { 'android-28': }
  android::build_tools { 'build-tools-28.0.3': }

  file { '/root/.ssh':
    ensure       => 'directory',
    mode         => '755',
    owner        => 'root',
    group        => 'wheel',
  }
  file { '/root/.ssh/known_hosts':
    content      => $known_hosts,
    mode         => '644',
    owner        => 'root',
    group        => 'wheel',
  }

  file { '/var/lib/jenkins/.ssh/known_hosts':
    content      => $known_hosts,
    mode         => '644',
  }
  file { '/var/lib/jenkins/.ssh/id_rsa':
    content      => $jenkins_ssh_private,
    mode         => '600',
  }
  file { '/var/lib/jenkins/.ssh/id_rsa.pub':
    content      => $jenkins_ssh_public,
    mode         => '644',
  }

  class { 'jenkins':
    executors          => 1,
    configure_firewall => false,
    install_java       => false,
#    cli_ssh_keyfile    => '/var/lib/jenkins/.ssh/id_rsa.pub',
  }

  class { 'jenkins::security':
    security_model     => 'full_control',
  }

  jenkins::user { 'brad':
    full_name          => 'Brad Rushworth',
    email              => 'brushworth@bitbot.com.au',
    password           => $jenkins_brad_password,
    public_key         => $jenkins_ssh_public,
  }

  jenkins::credentials { 'brad':
    uuid               => '48b1acb1-9cd8-43bd-8b78-b119bbf556e7',
    password           => $redmine_brad_password,
  }

  jenkins::plugin { 'workflow-api': }
  jenkins::plugin { 'workflow-step-api': }
  jenkins::plugin { 'workflow-scm-step': }
  jenkins::plugin { 'git': }
  jenkins::plugin { 'subversion': }
  jenkins::plugin { 'git-client': }
  jenkins::plugin { 'scm-api': }
  jenkins::plugin { 'mailer': }
  jenkins::plugin { 'ssh-credentials': }
  jenkins::plugin { 'matrix-project': }
  jenkins::plugin { 'mapdb-api': }
  jenkins::plugin { 'apache-httpcomponents-client-4-api': }
  jenkins::plugin { 'jsch': }
  jenkins::plugin { 'display-url-api': }
  jenkins::plugin { 'junit': }
  jenkins::plugin { 'script-security': }

}
