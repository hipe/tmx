#include <stdio.h>
#include "foo/bar-baz.h"

int whatever_main(void) {
  puts(foo_bar_baz());
  puts("Ok.");
  return 0;
}
