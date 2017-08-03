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

  action callish_identifier_action {
    printf( "identifier: \"%s\"\n", fsm->buffer );
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
    $err{ printf( "CI err\n" ); }
    >clear $append %term
    %callish_identifier_action
    ;

  ws = [ \t] ;

  true_keyword =
    'true'i
    $err{ printf( "err: true keyword\n" ); }
    ;

  test =
    identifier
    $err{ printf( "err: test identifier\n" ); }
    ws*
    '=='
    $err{ printf( "err: equals equals\n" ); }
    ws*
    "'"
    $err{ printf( "err: open single quote\n" ); }
    identifier
    $err{ printf( "err: single quote body\n" ); }
    "'"
    $err{ printf( "err: close single quote\n" ); }
    ;

  AND_tests =
    (
      ws*
      '&&'
      $err{ printf( "err: AND AND\n" ); }
      ws*
      test
      $err{ printf( "err: subsequent\n" ); }
    )+
    ;

  OR_tests =
    (
      ws*
      '||'
      $err{ printf( "err: OR OR\n" ); }
      ws*
      test
      $err{ printf( "err: subsequent OR test\n" ); }
    )+
    ;

  tests = test ( AND_tests | OR_tests )? ;

  root_test =
    ( tests | true_keyword )
    ;

  main :=
    callish_identifier
    '('
    $err{ printf( "err: open paren\n" ); }
    ws*
    root_test
    ws*
    ')'
    $err{ printf( "err: close paren\n" ); }
    0
    $err{ printf( "err: end of string\n" ); }
    @{ res = 1; }
    ;

}%%

%% write data;

void my_thing_init( struct my_struct * fsm )
{
  fsm->buflen = 0;
  %% write init;
}

int my_thing_execute( struct my_struct *fsm, const char *data, int len )
{
  const char *p = data;
  const char *pe = data + len;

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
