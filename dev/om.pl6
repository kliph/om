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

sub debug-stuff($copy, $name, $date){
  my $text = "$name/$date.org".&slurp;
  say $copy;
  say $text;
}

sub MAIN($date, Bool :$with-agenda = True, Bool :$with-notes = False, Bool :$all = True, *@user-names) {
  my %config = 'config.json'.&slurp.&from-json;
  my %names-to-emails = %config{'user-names'};
  my $copy = config-to-copy(%config, $with-notes);
  if @user-names {
    for @user-names -> $name {
      my $email = %names-to-emails{$name};
      debug-stuff($copy, $name, $date);
    }
  }
  elsif $all {
    for %names-to-emails.kv -> $name, $email {
      debug-stuff($copy, $name, $date);
    }
  }
}
