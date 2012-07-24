#include <ncurses.h>
#include <stdlib.h>

typedef struct {
  WINDOW *window;
  int width;
  int height;
  int x;
  int y;
} hipe_div;

hipe_div  *hipe_div_create(int h, int w, int y, int x);
void       hipe_div_draw(hipe_div *div);
