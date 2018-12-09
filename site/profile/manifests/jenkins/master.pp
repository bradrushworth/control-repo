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

  java_ks { 'jenkins_truststore':
    ensure       => latest,
    certificate  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    target       => '/var/lib/jenkins/truststore.jks',
    password     => 'changeit',
    trustcacerts => true,
  }

  java_ks { 'jenkins_keystore':
    ensure              => latest,
    certificate         => '/etc/puppetlabs/puppet/ssl/certs/jenkins.bitbot.net.au.pem',
    private_key         => '/etc/puppetlabs/puppet/ssl/private_keys/jenkins.bitbot.net.au.pem',
    private_key_type    => 'rsa',
    target              => '/var/lib/jenkins/jenkins.jks',
    password            => $jenkins_brad_password,
    password_fail_reset => true,
  }

#  class { 'android':
#    user         => 'jenkins',
#    group        => 'jenkins',
#    installdir   => '/usr/local/android',
#  }
#  android::platform { 'android-28': }
#  android::build_tools { 'build-tools-28.0.3': }

# cd /usr/local/android
# wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
# yum install unzip
# mkdir android-sdk-linux
# unzip sdk-tools-linux-4333796.zip android-sdk-linux
# ./tools/bin/sdkmanager --update
# ./tools/bin/sdkmanager "build-tools;28.0.3"
# ./tools/bin/sdkmanager --licenses
# ANDROID_HOME = /usr/local/android/android-sdk-linux

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
    config_hash => {
      'JENKINS_AJP_PORT'                => { 'value' => '9009' },
      'JENKINS_PORT'                    => { 'value' => '8080' },
      'JENKINS_LISTEN_ADDRESS'          => { 'value' => '127.0.0.1' },
      'JENKINS_HTTPS_LISTEN_ADDRESS'    => { 'value' => '0.0.0.0' },
      'JENKINS_HTTPS_PORT'              => { 'value' => '8443' },
      'JENKINS_HTTPS_KEYSTORE'          => { 'value' => '/var/lib/jenkins/jenkins.jks' },
      'JENKINS_HTTPS_KEYSTORE_PASSWORD' => { 'value' => $jenkins_brad_password },
    },
    configure_firewall => false,
    install_java       => false,
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
  jenkins::plugin { 'gradle': }
  jenkins::plugin { 'bouncycastle-api': }
  jenkins::plugin { 'command-launcher': }
  jenkins::plugin { 'jdk-tool': }
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

#  jenkins::job { 'aus-phone-towers':
#    config => template("${templates}/aus-phone-towers.xml.erb"),
#  }

}
