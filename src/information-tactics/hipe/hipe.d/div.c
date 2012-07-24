#include "div.h"

/*
#include <string.h>
*/

hipe_div *hipe_div_create(int w, int h, int y, int x) {
  hipe_div *d = (hipe_div *) malloc(sizeof(hipe_div));
  d->width = w ; d->height = h ; d->y = y ; d->x = x ;
  d->window = newwin(d->height, d->width, d->y, d->x);
  return d;
}

void hipe_div_draw(hipe_div * d) {
  box(d->window, 0, 0);
  wrefresh(d->window);
}
