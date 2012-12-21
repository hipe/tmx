#include <stdlib.h>

#include "nkurses.h"

typedef struct hipe_div hipe_div;

hipe_div *hipe_div_create(int h, int w, int y, int x);

struct hipe_div {
  void (*draw)(hipe_div *);
  WINDOW *window;
  int width;
  int height;
  int x;
  int y;
};
