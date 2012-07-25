#include "nkurses.h"

void hipe_nkurses_blah(char *msg) {
  attron(A_REVERSE);
  mvprintw(8, 16, msg);
  refresh();
  attroff(A_REVERSE);
}

bool hipe_nkurses_init(void) {
  initscr();
  clear();
  noecho();
  cbreak();
  mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, NULL);
  return OKAY;
}
