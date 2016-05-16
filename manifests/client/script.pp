# rdiff_backup::client::script class
class rdiff_backup::client::script(
  $path,
  $rdiffbackuptag,
  $rdiff_server,
  $remote_path,
  $rdiff_user,
  $backup_script,
) inherits rdiff_backup::params{

  concat { $backup_script:
    owner => 'root',
    group => 'root',
    mode  => '0700',
    tag   => $rdiffbackuptag,
  }

  concat::fragment{ 'backup_script_header':
    target  => $backup_script,
    content => "#!/bin/sh\n",
    order   => '01',
    tag     => $rdiffbackuptag,
  }

}
