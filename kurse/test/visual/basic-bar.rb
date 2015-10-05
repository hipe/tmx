#!/usr/bin/env ruby

require 'ncurses'
@nc = Ncurses
puts "about to initscr"
@scr = @nc.initscr
@nc.start_color
BAR_COLOR = 1
@nc.init_pair(BAR_COLOR, @nc::COLOR_WHITE, @nc::COLOR_BLUE)

x, y = @nc.getyx(@scr, x=[], y=[]) || [x.first, y.first]
@nc.COLS


@bar = Ncurses::WINDOW.new(1, Ncurses.COLS * 0.30, 0, 0)
@bar.bkgd(@nc.COLOR_PAIR(BAR_COLOR))
@bar.move(0, 0)
@bar.addstr("ohai hello")
@bar.noutrefresh
@nc.doupdate


sleep(0.7)
@bar.wresize(1, Ncurses.COLS * 0.7)
@bar.move(0, 0)
@bar.addstr("hello again")
@bar.noutrefresh
@nc.doupdate


sleep(0.7)
@bar.wresize(1, Ncurses.COLS)
@bar.move(0, 0)
@bar.addstr("done!")
@bar.noutrefresh
@nc.doupdate

# @scr.refresh
sleep(0.7)

