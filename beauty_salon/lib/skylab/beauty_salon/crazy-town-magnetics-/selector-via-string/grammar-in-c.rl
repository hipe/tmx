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
    >clear $append %term
    %callish_identifier_action
    >err{ printf( "error 1 (start)\n" ); }  # YES
    <>err{ printf( "error 1 (middle)EVER?\n" ); }  # NUNCA
    # %err{ printf( "error 1 (final)\n" ); }  # YES
    ;

  ws = [ \t] ;

  true_keyword = 'true'i @true_action ;

  # interesting_body = ( identifier - 'true'i )
  #   >clear $append %term
  #   %interesting_body_action
  #   ;

  quoted_string = "'"  [^']+  "'"  ;  # not start with WS - NOTE!!! ROUGH MOCKUP !!

  regexp_yikes = '/'  [^/]+  '/'   ; # not start with WS - NOTE!!! ROUGH MOCKUP !!

  equals_string_predicate = '==' ws* quoted_string ;  # not start with WS

  match_predicate = '=~' ws* regexp_yikes ;

  test = identifier ws* ( equals_string_predicate | match_predicate ) ;  # not start with WS

  subsequent_test = test ;  # not start with WS

  or_list = ( '||' ws* subsequent_test ws* )+ ;

  and_list = ( '&&' ws* subsequent_test ws* )+ ;

  first_test = test ;  # not start with WS

  interesting_body = first_test ws* ( and_list | or_list )? ;

  callish_body =
    (
      (
        '('
        >err{ printf( "error 2A (start)\n"); }
        <>err{ printf( "error 2A (middle) EVER?\n"); }
        # %err{ printf( "error 2A (final)\n"); }
      )
      ws*
      (
        ( interesting_body | true_keyword )
        >err{ printf( "error 2B (start)\n"); }
        <>err{ printf( "error 2B (middle) EVER?\n"); }
        # %err{ printf( "error 2B (final)\n"); }
      )
      ws*
      (
        ')'
        >err{ printf( "error 2C (start)\n"); }
        <>err{ printf( "error 2C (middle) EVER?\n"); }
        # %err{ printf( "error 2C (final)\n"); }
      )
    )
    ;

  finish =
    0
    @{ res = 1; }
    >err{ printf( "error 3 (start)\n"); }  # when trailing WS
    <>err{ printf( "error 3 (middle) EVER?\n"); }
    %err{ printf( "error 3 (final) EVER?\n"); }
    ;

  main := callish_identifier callish_body finish ;

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

  printf( "result = %i\n", res );

  return 0;
}
// born.
