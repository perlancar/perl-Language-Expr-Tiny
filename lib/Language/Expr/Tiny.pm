package Language::Expr::Tiny;

use 5.010001;
use strict;
use warnings;

our $FROM_JSON = qr{

(?&VALUE) (?{ $_ = $^R->[1] })

(?(DEFINE)

(?<OBJECT>
  (?{ [$^R, {}] })
  \{\s*
    (?: (?&KV) # [[$^R, {}], $k, $v]
      (?{ # warn Dumper { obj1 => $^R };
	 [$^R->[0][0], {$^R->[1] => $^R->[2]}] })
      (?: \s*,\s* (?&KV) # [[$^R, {...}], $k, $v]
        (?{ # warn Dumper { obj2 => $^R };
	   [$^R->[0][0], {%{$^R->[0][1]}, $^R->[1] => $^R->[2]}] })
      )*
    )?
  \s*\}
)

(?<KV>
  (?&STRING) # [$^R, "string"]
  \s*:\s* (?&VALUE) # [[$^R, "string"], $value]
  (?{ # warn Dumper { kv => $^R };
     [$^R->[0][0], $^R->[0][1], $^R->[1]] })
)

(?<ARRAY>
  (?{ [$^R, []] })
  \[\s*
    (?: (?&VALUE) (?{ [$^R->[0][0], [$^R->[1]]] })
      (?: \s*,\s* (?&VALUE) (?{ # warn Dumper { atwo => $^R };
			 [$^R->[0][0], [@{$^R->[0][1]}, $^R->[1]]] })
      )*
    )?
  \s*\]
)

(?<VALUE>
  \s*
  (
      (?&STRING)
    |
      (?&NUMBER)
    |
      (?&OBJECT)
    |
      (?&ARRAY)
    |
    true (?{ [$^R, 1] })
  |
    false (?{ [$^R, 0] })
  |
    null (?{ [$^R, undef] })
  )
  \s*
)

(?<STRING>
  (
    "
    (?:
      [^\\"]+
    |
      \\ ["\\/bfnrt]
#    |
#      \\ u [0-9a-fA-f]{4}
    )*
    "
  )

  (?{ [$^R, eval $^N] })
)

(?<NUMBER>
  (
    -?
    (?: 0 | [1-9]\d* )
    (?: \. \d+ )?
    (?: [eE] [-+]? \d+ )?
  )

  (?{ [$^R, eval $^N] })
)

) }xms;

sub from_json {
    local $_ = shift;
    local $^R;
    eval { m{\A$FROM_JSON\z}; } and return $_;
    die $@ if $@;
    die 'no match';
}


1;
# ABSTRACT: Parse Expr

=head1 DESCRIPTION

This module parse some subset of the Expr language. It uses only Perl regular
expression to do this, but requires 5.10 because of the required regex features.

=head1 SEE ALSO

L<Language::Expr::Manual::Syntax>

