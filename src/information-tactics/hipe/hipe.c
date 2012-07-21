/*
 * this shit is on
 * this is the first hipe shit in c in the modern era
 * it is not the last
 *
 */

#include <ncurses.h>
#include <string.h>

void hipe_init_ncurses() {
	initscr();
	clear();
	noecho();
	cbreak();
	mousemask(ALL_MOUSE_EVENTS, NULL);
}

int main() {
	hipe_init_ncurses();
	attron(A_REVERSE);
	mvprintw(8, 16, "So halloez there friend\n\n\n\n\n\n\n");
	refresh();
	attroff(A_REVERSE);
}
