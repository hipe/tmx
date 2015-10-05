#include "demo.h"

#define HIPE_DEMO_COL_MAIN     5
#define HIPE_DEMO_ROW_MICRO    1
#define HIPE_DEMO_ROW_MINI     2
#define HIPE_DEMO_ROW_FEED     3
#define HIPE_DEMO_ROW_ANNOUCE  4

#define HIPE_DEMO_DELAY_TENTHS 7

typedef struct hipe_demo hipe_demo;

struct hipe_demo {
  bool (*run)(hipe_demo *);

  bool (*char_entered)(hipe_demo *, int c);
  bool (*mouse_buttoned)(hipe_demo *);
  bool (*mouse_moved)(hipe_demo *, unsigned int y, unsigned int x);

  hipe_div *div;
};

void hipe_demo_tick(unsigned int little, unsigned int big) {
  mvprintw(HIPE_DEMO_ROW_MICRO, HIPE_DEMO_COL_MAIN, "event tick %5d/%7d", little, big); refresh();
}

bool hipe_demo_event_loop(hipe_demo *demo) {
  int prev_y = -1 ; int prev_x = -1 ; int y ; int x ;
  halfdelay(HIPE_DEMO_DELAY_TENTHS); // overrides cbreak maybe?
  bool do_loop = false;
  int __tic = 0 ; int _ = 0 ;
  do {
    hipe_demo_tick(_, ++__tic);
    getyx(demo->div->window, y, x);
    if (prev_y != y || prev_x != x) {
      prev_y = y ; prev_x = x ;
      _++;
      mvprintw(HIPE_DEMO_ROW_MINI, HIPE_DEMO_COL_MAIN, "cursor moved to y:%d x:%d (tick %d)", y, x, __tic); refresh();
      do_loop = demo->mouse_moved(demo, y, x);
    } else {
      bool do_ch;
      do {
        do_ch = false;
        int c = getch();
        switch (c) {
          case       ERR : do_loop = true ; break ; // nothing was pressed before halfdelay expired.
          case KEY_MOUSE : _++; do_loop = do_ch = demo->mouse_buttoned(demo)   ; break ;
          default        : _++; do_loop = do_ch = demo->char_entered(demo, c)  ; break ;
        }
      } while (do_ch);
    }
  } while(do_loop);
  return OKAY;
}

bool hipe_demo_char_entered(hipe_demo *demo, int c) {
  mvprintw(HIPE_DEMO_ROW_FEED, HIPE_DEMO_COL_MAIN, "char entered: %c", c); refresh();
  if ('q' == c) return false;
  return true;
}

bool hipe_demo_mouse_buttoned(hipe_demo *demo) {
  MEVENT e;
  if (getmouse(&e)) return FAILED;
  mvprintw(HIPE_DEMO_ROW_ANNOUCE, HIPE_DEMO_COL_MAIN, hipe_mouse_event_describe(&e)); refresh();
  return true;
}

bool hipe_demo_mouse_moved(hipe_demo *demo, unsigned int y, unsigned int x) {
  return true;
}

bool hipe_demo_run(hipe_demo *demo) {
  mousemask(ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, NULL);
  noecho();
  cbreak();
  keypad(stdscr, TRUE);
  hipe_div *d = hipe_div_create(20, 60, 5, 5);
  demo->div = d;
  d->draw(d);
  bool result = hipe_demo_event_loop(demo);
  free(d);
  demo->div = NULL;
  return result;
}

hipe_demo *hipe_demo_create() {
  hipe_demo *d = malloc(sizeof(hipe_demo));
  d->run = hipe_demo_run;
  d->char_entered   = hipe_demo_char_entered;
  d->mouse_buttoned = hipe_demo_mouse_buttoned;
  d->mouse_moved    = hipe_demo_mouse_moved;
  return d;
}

int hipe_demo_main(void) {
  hipe_demo *d = hipe_demo_create();
  bool b = hipe_ncurses_session((hipe_runner *)d);
  free(d);
  return(b ? OK : ERR);
}
