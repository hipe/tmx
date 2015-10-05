#include "div.h"

void hipe_div_draw(hipe_div *d) {
  refresh();
  box(d->window, 0, 0);
  wrefresh(d->window);
}

hipe_div *hipe_div_create(int h, int w, int y, int x) {
  hipe_div *d = (hipe_div *) malloc(sizeof(hipe_div));
  d->draw = hipe_div_draw;
  d->width = w ; d->height = h ; d->y = y ; d->x = x ;
  d->window = newwin(d->height, d->width, d->y, d->x);
  return d;
}
