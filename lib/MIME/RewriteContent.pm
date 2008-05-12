use strict;
use warnings;
package MIME::RewriteContent;

use Encode;
use MIME::Entity;
use Variable::Magic ();

sub rewrite_content {
  my ($self, $entity, $code) = @_;

  my $charset = $entity->head->mime_attr('content-type.charset')
             || 'ISO-8859-1';

  my $changed = 0;
  my $got_set = Variable::Magic::wizard(set => sub { $changed = 1 });

  my $body = Encode::decode($charset, $entity->bodyhandle->as_string);
  Variable::Magic::cast($body, $got_set);
  $code->(\$body, $entity);

  if ($changed) {
    my $io = $entity->open('w');
    $io->print(Encode::encode($charset, $body));
  }
}

sub rewrite_lines {
  my ($self, $entity, $code) = @_;

  my $charset = $entity->head->mime_attr('content-type.charset')
             || 'ISO-8859-1';

  my $changed = 0;
  my $got_set = Variable::Magic::wizard(set => sub { $changed = 1 });

  my @lines = $entity->bodyhandle->as_lines;

  for my $line (@lines) {
    local $_ = Encode::decode($charset, $line);
    Variable::Magic::cast($_, $got_set);
    $code->(\$_, $entity);
    Variable::Magic::dispell($_, $got_set);
    $line = $_;
  };

  if ($changed) {
    my $io = $entity->open('w');
    $io->print(Encode::encode($charset, $_)) for @lines;
  }
}

1;
