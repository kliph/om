# $ perl6 om.pl6
# Usage:
#   om.pl6 [--with-agenda] [--with-notes] [--all] <date> '[<user-names> ...]'

use JSON::Tiny;

sub config-to-copy(%c, $with-notes) {
  if $with-notes {
    return %c{'notes-copy'};
  }
  return %c{'agenda-copy'};
}

sub config-to-subject(%c, $with-notes) {
  if $with-notes {
    return %c{'notes-subject'};
  }
  return %c{'agenda-subject'};
}


sub send-email-when-file-exists(%h (Str :$email-address, Str :$copy, Str :$name, Str :$date, Str :$subject, Str :$from)){
  my $file = "$name/$date.org".IO;
  when $file.e {
    my $text = $file.slurp;

    my $email = qq:to/END/;
To: $email-address
From: $from
Subject: $subject
$copy

$text
END

    my $shell-cmd = qq[printf "$email" | msmtp --account=default --from=$from $email-address];
    say $shell-cmd;
    shell $shell-cmd;
  };

}

sub MAIN($date, Bool :$with-agenda = True, Bool :$with-notes = False, Bool :$all = True, *@user-names) {
  my %config = 'config.json'.&slurp.&from-json;
  my %names-to-emails = %config{'user-names'};
  my $copy = config-to-copy(%config, $with-notes);
  my $subject = config-to-subject(%config, $with-notes);
  my $from = %config{'from'};
  my %params = %(
    :$copy,
    :$subject,
    :$date,
    :$from
  );

  if @user-names {
    for @user-names -> $name {
      my $email = %names-to-emails{$name};
      send-email-when-file-exists(
        %(
          %params,
          :email-address($email),
          :$name
        )
      );
    }
  } elsif $all {
    for %names-to-emails.kv -> $name, $email {
      send-email-when-file-exists(
        %(
          %params,
          :email-address($email),
          :$name
        )
      );
    }
  }
}
