#include "demo.h"

bool hipe_demo_on_mouse(MEVENT *event);
bool hipe_demo_run(void);

int hipe_demo_main(void) {
  if (!hipe_nkurses_init()) return ERR;
  refresh(); // one day i will know why this is necessary here
  hipe_div *d = hipe_div_create(61, 15, 5, 3);
  hipe_div_draw(d);
  return(hipe_demo_run() ? OK : ERR);
}

bool hipe_demo_run(void) {
  int c ; MEVENT e ; bool loop = true ;
  keypad(stdscr, TRUE);
  while (loop) {
    switch(c = getch()) {
      case KEY_MOUSE: getmouse(&e) || (hipe_demo_on_mouse(&e) || (loop = false)) ; break ;
    }
  }
  endwin();
  return OKAY;
}

bool hipe_demo_on_mouse(MEVENT *e) {
  mvprintw(1, 1, hipe_mouse_event_describe(e));
  refresh();
  return OKAY;
}
