/*
 * this shit is on
 * this is the first hipe shit in c in the modern era
 * it is not the last
 *
 */

#include <stdlib.h>
#include <ncurses.h>
#include <string.h>

typedef struct {
  WINDOW *window;
  int width;
  int height;
  int x;
  int y;
} hipe_div;

hipe_div  *hipe_div_create(int h, int w, int y, int x);
void       hipe_div_draw(hipe_div *div);
void       hipe_ncurses_init(void);

int main() {
  hipe_ncurses_init();

  attron(A_REVERSE);
  mvprintw(8, 16, "So halloez there friend");
  refresh();
  attroff(A_REVERSE);
  hipe_div *d = hipe_div_create(60, 15, 5, 3);
  hipe_div_draw(d);

  int c;
  MEVENT event;
  while(1) {
    keypad(stdscr, TRUE);
    c = getch();
    switch(c) {
      case KEY_MOUSE: {
        if (getmouse(&event) == OK) {
          if (event.bstate & BUTTON1_CLICKED) {
            mvprintw(1, 1, "nerk derk is : %d, %d", event.x, event.y);
            refresh();
          }
        }
      }
    }
  }
  //endwin();
  //return 0;
}

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

void hipe_ncurses_init(void) {
  initscr();
  clear();
  noecho();
  cbreak();
  mousemask(ALL_MOUSE_EVENTS, NULL);
}
