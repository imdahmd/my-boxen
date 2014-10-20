require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  include nodejs::v0_6
  include nodejs::v0_8
  include nodejs::v0_10

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  # custom
  include java
  include atom
  include iterm2::stable
  class { 'intellij':
    edition => 'ultimate',
    version => '13.1.5'
  }
  class { 'vlc':
    version => '2.1.5'
  }
  include chrome

  # git global configs
  git::config::global { 'user.email':
    value  => 'imdhmd@gmail.com'
  }
  git::config::global { 'user.name':
    value  => 'Imdad Ahmed'
  }
  git::config::global { 'push.default':
    value  => 'simple'
  }
  git::config::global { 'alias.co':
    value  => 'checkout'
  }
  git::config::global { 'alias.ci':
    value  => 'commit'
  }
  git::config::global { 'alias.st':
    value  => 'status'
  }
  git::config::global { 'alias.pr':
    value  => 'pull --rebase'
  }
  git::config::global { 'alias.d':
    value  => 'diff'
  }
  git::config::global { 'alias.ds':
    value  => 'diff --staged'
  }
  git::config::global { 'alias.cmr':
    value  => 'commit --amend --reset-author'
  }
  git::config::global { 'alias.l':
    value  => 'log --oneline'
  }
}
