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

  action money_town_action {
    printf( "money town: \"%s\"\n", fsm->buffer );
  }

  action true_action {
    printf( "(true town)\n" );
  }

  # --


  identifier = [a-z] [_a-z0-9]* ;

  ws = [ \t] ;

  true_keyword = 'true'i @true_action ;

  money_town = ( identifier - 'true'i ) >clear $append %term @money_town_action;

  body = ( money_town | true_keyword ) ;

  main := identifier '(' ws* body ws* ')' 0 @{ res = 1; };

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
