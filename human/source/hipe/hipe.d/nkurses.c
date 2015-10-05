#include "nkurses.h"

bool hipe_ncurses_session(hipe_runner *runner) {
  initscr();
  bool result = runner->run(runner);
  endwin();
  return result;
}
