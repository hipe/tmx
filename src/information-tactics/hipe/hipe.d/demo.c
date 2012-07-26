#include "demo.h"

typedef struct hipe_demo hipe_demo;

struct hipe_demo {
  bool (*run)(hipe_demo *);

  bool (*get_char)(hipe_demo *);
  bool (*on_char)(hipe_demo *, int c);
  bool (*on_mouse)(hipe_demo *);

  hipe_div *div;
};

bool hipe_demo_getch(hipe_demo* demo) {
  int c;
  bool keep_going;
  switch (c = getch()) {
    case     KEY_MOUSE : keep_going = demo->on_mouse(demo);   break;
    default            : keep_going = demo->on_char(demo, c); break;
  }
  return keep_going;
}

bool hipe_demo_on_char(hipe_demo *demo, int c) {
  if ('q' == c) return false;
  mvprintw(3, 5, "some character: %c (do 'q' for quit)", c);
  refresh();
  return OKAY;
}

bool hipe_demo_on_mouse(hipe_demo *demo) {
  MEVENT e;
  if (getmouse(&e)) return FAILED;
  mvprintw(2, 5, hipe_mouse_event_describe(&e));
  refresh();
  return OKAY;
}

bool hipe_demo_run(hipe_demo *demo) {
  mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, NULL);
  noecho();
  cbreak();
  keypad(stdscr, TRUE);
  hipe_div *d = hipe_div_create(20, 60, 5, 5);
  d->draw(d);
  demo->div = d;
  while (demo->get_char(demo));
  free(d);
  demo->div = NULL;
  return OKAY;
}

hipe_demo *hipe_demo_create() {
  hipe_demo *d = malloc(sizeof(hipe_demo));
  d->run = hipe_demo_run;
  d->get_char = hipe_demo_getch;
  d->on_char = hipe_demo_on_char;
  d->on_mouse = hipe_demo_on_mouse;
  return d;
}

int hipe_demo_main(void) {
  hipe_demo *d = hipe_demo_create();
  bool b = hipe_ncurses_session((hipe_runner *)d);
  free(d);
  return(b ? OK : ERR);
}
