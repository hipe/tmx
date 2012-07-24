#include "demo.h"

bool hipe_demo_run(void);

int hipe_demo_main(void) {
  if (!hipe_nkurses_init()) return ERR;
  refresh(); // one day i will know why this is necessary here
  hipe_div *d = hipe_div_create(61, 15, 5, 3);
  hipe_div_draw(d);
  return(hipe_demo_run() ? OK : ERR);
}

bool hipe_demo_run(void) {
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
  return OKAY;
}
