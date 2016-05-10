#new rdiff_export
define rdiff_backup::rdiff_export (
  $ensure = undef,
  $chroot = true,
  $readonly = true,
  $mungesymlinks = true,
  $path = undef,
  $uid = undef,
  $gid = undef,
  $users = undef,
  $secrets = undef,
  $deny = undef,
  $prexferexec = undef,
  $postxferexec = undef,
  $remote_path = undef,
  $rdiff_server = undef,
  $rdiffbackuptag = undef,
  $allow = undef,
){

  if ($path) {
    $cleanpath = regsubst($path, '\/', '-', 'G')
  }

  $password = generate('/usr/bin/pwgen', 8, 1)

  if $secrets == undef and !('' in [$secrets]) {
    $_secrets = "/etc/${::fqdn}${cleanpath}-rsyncd.secret"
  }
  else {
    $_secrets = $secrets
  }

  create_resources('@@file', { $_secrets => {
    content => "${::fqdn}${cleanpath}:${password}",
    replace => no,
    mode    => '0460',
    owner   => $uid,
    group   => $gid,
    tag     => $rdiffbackuptag
  }})


  create_resources('@@rsyncd::export', {"${::fqdn}${cleanpath}" => {
    ensure        => $ensure,
    chroot        => $chroot,
    readonly      => $readonly,
    mungesymlinks => $mungesymlinks,
    path          => $remote_path,
    uid           => $uid,
    gid           => $gid,
    users         => $users,
    secrets       => $_secrets,
    allow         => $allow,
    deny          => $deny,
    prexferexec   => $prexferexec,
    postxferexec  => $postxferexec,
    tag           => $rdiffbackuptag
  }})

  create_resources('@@file', { "${::fqdn}${cleanpath}" => {
    ensure => directory,
    path   => $remote_path,
    owner  => $uid,
    group  => $gid,
    tag    => $rdiffbackuptag,
  }})

  cron{ "${::fqdn}${cleanpath}":
    #lint:ignore:80chars
    command => "rdiff-backup ${path} ${::fqdn}${cleanpath}@${rdiff_server}::${::fqdn}${cleanpath}",
    #lint:endignore
    user    => $uid,
    hour    => 1,
  }
}
