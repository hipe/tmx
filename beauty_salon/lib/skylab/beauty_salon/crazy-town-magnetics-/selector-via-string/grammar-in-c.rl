#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// (writing this in C so we can follow the book examples easier for now..)

#define BUFLEN 1024

struct my_struct
{
	char buffer[ BUFLEN + 1 ];
	int buflen;
	int cs;
};

%%{
  machine foo;

  access fsm->;

  # append to the buffer
  action append {
    if ( fsm->buflen < BUFLEN )
      fsm->buffer[ fsm->buflen ++ ] = fc;
  }

  # terminate the buffer
  action term {
    if ( fsm->buflen < BUFLEN )
      fsm->buffer[ fsm->buflen ++ ] = 0;
  }

  # clear out the buffer
  action clear { fsm->buflen = 0; }

  # -- these actions

  action literal_string_body_action {
    printf( "literal string: \"%s\"\n", fsm->buffer );
  }

  action regex_body_action {
    printf( "regex body: \"%s\"\n", fsm->buffer );
  }

  action test_identifier_action {
    printf( "test identifier: \"%s\"\n", fsm->buffer );
  }

  action callish_identifier_action {
    printf( "callish identifier: \"%s\"\n", fsm->buffer );
  }

  action interesting_body_action {
    printf( "money town: \"%s\"\n", fsm->buffer );
  }

  action true_action {
    printf( "(true town)\n" );
  }

  # --

  identifier = [a-z] [_a-z0-9]* ;
    # note for now we allow no uppercase but there's a fair chance this will change..

  callish_identifier = identifier
    >err{ oops( "CI err start" ); }
    >clear $append %term
    %callish_identifier_action
    ;

  ws = [ \t] ;

  true_keyword =
    'true'i
    >err{ oops( "true keyword start" ); }
    ;

  single_quote_char =

    # this monstrosity is a workaround because when we use any of:
    #   - the subtraction operation, for example `any - ['\\']`
    #   - the negation operator, for example `[^a-z]`
    # it has the effect of "swallowing" the involved errors no matter how
    # we attempt to set hooks for them..

    ( [ -&(-[\]-~]
      # ' ' (space (32)) is the first printable character and '~' (tilde (126)) is the last
      # `[ -&]`  (space thru ampersand) are the printables before the single quote
      # `[(-[]`  (open paren thru open bracket) are the printables between single quote & backslash
      # `[\]-~]` (close bracket thru tilde) are the remaining ones
      |

      '\\' any
    )
    ;

  regex_char =

    # same deal as the above.
    # for now we're not that interesting in parsing regexes robustly..
    #
    #     ' '(32) '.'(46) '/'(47) '0'(48) '['(91) '\\'(92) ']'(93) '~'(126)

    [ -.0-[\]-~]
    |
    '\\' any
    ;

  regex_match_predicate =
    '=~'
    >err{ oops( "match operator start" ); }
    <>err{ oops( "match operator mid" ); }
    ws*
    '/'
    >err{ oops( "open forward slash" ); }
    ( regex_char * )
    >err{ oops( "regex body" ); }
    >clear $append %term
    %regex_body_action
    '/'
    >err{ oops( "close forward slash" ); }
    ;

  equals_predicate =
    '=='
    >err{ oops( "equals equals start" ); }
    <>err{ oops( "equals equals mid" ); }
    ws*
    "'"
    >err{ oops( "open single quote" ); }
    single_quote_char *
    >err{ oops( "single quote body" ); }
    "'"
    >err{ oops( "close single quote" ); }
    ;

  test =
    identifier
    >err{ oops( "test identifier start" ); }
    >clear $append %term
    %test_identifier_action
    ws*
    ( equals_predicate | regex_match_predicate )
    ;

  AND_tests =
    (
      ws*
      '&&'
      >err{ oops( "AND AND begin" ); }
      <>err{ oops( "AND AND middle" ); }
      ws*
      test
    )+
    ;

  OR_tests =
    (
      ws*
      '||'
      >err{ oops( "OR OR begin" ); }
      <>err{ oops( "OR OR middle" ); }
      ws*
      test
    )+
    ;

  tests = test ( AND_tests | OR_tests )? ;

  root_test =
    ( tests | true_keyword )
    ;

  main :=
    callish_identifier
    '('
    >err{ oops( "open paren start" ); }
    ws*
    root_test
    ws*
    ')'
    >err{ oops( "close paren" ); }
    0
    >err{ oops( "end of string" ); }
    @{ res = 1; }
    ;

}%%

%% write data;

void my_thing_init( struct my_struct * fsm )
{
  fsm->buflen = 0;
  %% write init;
}

// YUCK we turned these into globals only for error reporting
const char * orig_data;
const char * p;
const char * pe;

void oops( char str[] ) {

  printf( "err %s:\n", str );

  printf( "  %s\n", orig_data );

  int offset_into_data_string  = (int)( p - orig_data );

  size_t _glyph_width = offset_into_data_string + 1;

  char *glyph = malloc( _glyph_width );
  glyph[ 0 ] = 0;  // yuck, make it a null-terminated string

  int count = offset_into_data_string;

  while ( 0 != count -- ) {
    strcat( glyph, "-" );
  }

  strcat( glyph, "^" );

  printf( "  %s\n", glyph );
  free( glyph );
}

int my_thing_execute( struct my_struct *fsm, const char *data, int len )
{
  orig_data = data;
  p = data;
  pe = data + len;

  int res = 0;
  char *eof = 0; // ??

  %% write exec;

  return res;
}

#define BUFSIZE 2048

int main( int argc, char **argv )
{

  struct my_struct actual_struct ;
  struct my_struct *fsm = & actual_struct ;

  int res = -1;

  if ( argc > 1 ) {

    my_thing_init( fsm );
    res = my_thing_execute( fsm, argv[1], strlen( argv[1] ) + 1 );
  }

  switch (res) {
    case 1 :
      printf( "yay.\n" ); break ;
    case 0 :
      printf( "failed to parse.\n" ); break ;
    default :
      printf( "unexpected result: %i\n", res );
  }
}
// born.
