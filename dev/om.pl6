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


sub debug-stuff($email, $copy, $name, $date, $subject){
  send-email($email, $copy, $name, $date, $subject)
}

sub send-email($email-address, $copy, $name, $date, $subject){
  my $text = "$name/$date.org".&slurp;

  my $email = qq:to/END/;
To: $email-address
From: me@example.com
Subject: $subject
$copy

$text
END

  my $shell-cmd = qq[printf "$email" | msmtp --account=default --from=me@example.com $email-address];
  say $shell-cmd;
  shell $shell-cmd;
  # printf "To: me@example.com\nFrom: me@example.com\nSubject: ayy lol\n\nHello there." | msmtp --account=default --from=me@example.com me@example.com

}

sub MAIN($date, Bool :$with-agenda = True, Bool :$with-notes = False, Bool :$all = True, *@user-names) {
  my %config = 'config.json'.&slurp.&from-json;
  my %names-to-emails = %config{'user-names'};
  my $copy = config-to-copy(%config, $with-notes);
  my $subject = config-to-subject(%config, $with-notes);
  if @user-names {
    for @user-names -> $name {
      my $email = %names-to-emails{$name};
      send-email($email, $copy, $name, $date, $subject);
    }
  }
  elsif $all {
    for %names-to-emails.kv -> $name, $email {
      send-email($email, $copy, $name, $date, $subject);
    }
  }
}
