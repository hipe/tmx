require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Lipstick

  ::Skylab::Face::TestSupport::CLI[ self ]

  include Constants

  extend TestSupport_::Quickie

  Face_ = Face_

  describe "[fa] CLI::Lipstick" do

    it "an illustration of the steps for building and using a lipstick" do
      _LIPSTICK = Face_::CLI::Lipstick.new '*', :yellow, -> { 20 }
        # we want to render yellow '*' characters. a fallback width
        # is the (quite narrow) 20 characters, for the whole pane "screen"

      rendering_proc = _LIPSTICK.instance.cook_rendering_proc [ 12 ]
        # to "cook" a rendering function, we tell it that we will have a
        # table on the left half of the screen that has one column that
        # is 12 characters wide.

      ohai = rendering_proc[ 0.50 ]
        # to render we pass one float that is supposed to be a normalized
        # scalar between 0.0 and 1.0 inclusive.

      ( 3..150 ).include?( ohai.match( /\*+/ )[ 0 ].length ).should eql true
    end
    it "You can also render compound \"tuple ratios\"" do
      _LIPSTICK = Face_::CLI::Lipstick.new [ ['+', :green], ['-', :red] ]
        # first arg is instead an array of "pen tuples"
        # we chose not to provide a 2nd arg (default width function).

      p = _LIPSTICK.instance.cook_rendering_proc [ 28 ], 60
        # existing table is 1 column, 28 chars wide. explicitly set
        # the "panel" width to 60 (overriding any attempt at ncurses).

      ohai = p[ 0.50, 0.25 ]  # we have 32 chars to work within..
      num_pluses = /\++/.match( ohai )[ 0 ].length
      num_minuses = /-+/.match( ohai )[ 0 ].length
      num_pluses.should eql 15
      num_minuses.should eql 7
    end
  end
end
