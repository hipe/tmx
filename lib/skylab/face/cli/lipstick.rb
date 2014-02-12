module Skylab::Face

  class CLI::Lipstick < ::Module

    # a "lipstick" is an abstract rendering entity whose job it is to render
    # with glyphs (e.g "+" (pluses)) a certain normalized scalar (a "ratio"
    # between 0.0 and 1.0 inclusive), taking into account how wide the screen
    # is at some particular time, and how wide the "pane" is of available
    # screen-rendering real estate.
    #
    # its inspiration is the green and red pluses and minuses that appear in a
    # typical `git show --stat` (although we noticed only after implementing
    # this that `git show --stat` does not appear to exhibit the same
    # adaptive behavior that this "lipstick" facility exhibits.)
    #
    # to determine the width of the terminal, Lipstick requires the
    # `ruby-ncurses` gem, but if for some reason this is unavailable or the
    # terminal width otherwise cannot be determined dynamically, a fallback
    # width may be provided explicitly.
    #
    # although it has gone through three complete overahauls, the API is still
    # obtuse for reasons: to get to the rendering of a single "lipstick" series
    # of characters we must do three things: 1) create our own lipstick module.
    # 2) "cook" a rendering function. 3) call the function. The steps can be
    # simple, but are nonetheless separate currently. here is
    # an illustration of the steps for building and using a lipstick:
    #
    #     Lipstick = Face::CLI::Lipstick.new '*', :yellow, -> { 20 }
    #       # we want to render yellow '*' characters. a fallback width
    #       # is the (quite narrow) 20 characters, for the whole pane "screen"
    #
    #     rendering_proc = Lipstick.instance.cook_rendering_proc([12])
    #       # to "cook" a rendering function, we tell it that we will have a
    #       # table on the left half of the screen that has one column that
    #       # is 12 characters wide.
    #
    #     ohai = rendering_proc[ 0.50 ]
    #       # to render we pass one float that is supposed to be a normalized
    #       # scalar between 0.0 and 1.0 inclusive.
    #
    #     ( 3..150 ).include?( ohai.match( /\*+/ )[ 0 ].length ) # => true
    #       # the width you get may vary based on your terminal's width when
    #       # you run this!

    # You can also render compound "tuple ratios"
    # like so:
    #
    #     Lipstick = Face::CLI::Lipstick.new [['+', :green],['-', :red]]
    #       # first arg is instead an array of "pen tuples"
    #       # we chose not to provide a 2nd arg (default width function).
    #
    #     f = Lipstick.instance.cook_rendering_proc [ 28 ], 60
    #       # existing table is 1 column, 28 chars wide. explicitly set
    #       # the "panel" width to 60 (overriding any attempt at ncurses).
    #
    #     ohai = f[ 0.50, 0.25 ]  # we have 32 chars to work within..
    #     num_pluses = /\++/.match( ohai )[ 0 ].length
    #     num_minuses = /-+/.match( ohai )[ 0 ].length
    #     num_pluses # => 15
    #     num_minuses # => 7
    #

    # The reasons for the convoluted API are these: the multistep sequence is
    # an optimiztion. The first step, making your lipstick module, allows us
    # to store the raw "configuation data" about how you want to render things
    # without doing any heavy lifting at all -- this may come in handy if, for
    # example, you don't need to render any lipsticks at all during your
    # program execution. The second step, "cooking" your rendering function,
    # is where all the heavy lifting happens. in one step we hook out to
    # ncurses to determine screen width. then, on subsequence calls to your
    # rendering function, it only does as few calculations as necessary to
    # render its particular lipstick string.

    def initialize *a
      @a = a
      @instance = nil
      const_set :Class_, ::Class.new( Class__ )
      nil
    end

    def instance
      if ! @instance
        @instance = self::Class_.new( * @a )
      end
      @instance
    end

    def self.cols
      80  # #ncurses
    end
  end

  CLI::Lipstick::Class__ = Lib_::Procs_as_methods[ :cook_rendering_proc ]

  class CLI::Lipstick::Class__

    GLYPH_FALLBACK = '.'
    PANE_WIDTH_FALLBACK = 72

    Pen_ = Lib_::Procs_as_methods[ :cook ]

    class Pen_
      def initialize glyph, color
        glyph ||= GLYPH_FALLBACK
        1 == glyph.length or raise "glyph must be of length 1 (had #{
          }#{ glyph.inspect })"
        norm = -> x do
          [ [ x, 0.0 ].max, 1.0 ].min
        end
        @cook = -> my_room do
          # `normalized_float` below must be nil or btwn 0.0 and 1.0 inclusive
          styliz = if color
            CLI::Lib_::Stylify_proc[].curry[ [ color ] ]
          else IDENTITY_ end
          -> normalized_float do
            if normalized_float  # allow nil to mean "don't do it"
              styliz[ glyph * ( norm[ normalized_float ] * my_room ).to_i ]
            end
          end
        end
      end
      IDENTITY_ = -> x { x }
    end

    # `initialize`
    #   arguments: [glyph-string] [color-symbol] [default-cols-func]
    #          or: <tuple-array> [default-cols-func]
    #

    def initialize *args
      if args.length.nonzero? and args.fetch( 0 ).respond_to?(:each_with_index)
        tuple_a = args.shift
        default_width, = Lib_::Parse_series[ args,
          -> x { x.respond_to? :call } ]
        pen_a = tuple_a.map do |tpl_a|
          Pen_.new( * Lib_::Parse_series[ tpl_a,
            -> x { x.respond_to? :ascii_only? },
            -> x { x.respond_to? :id2name } ] )
        end
      else
        glyph, color, default_width = Lib_::Parse_series[ args,
          -> x { x.respond_to? :ascii_only? },
          -> x { x.respond_to? :id2name },
          -> x { x.respond_to? :call } ]
        pen_a = [ Pen_.new( glyph, color ) ]
      end
      default_width ||= -> { PANE_WIDTH_FALLBACK }
      min_room = 4 ; margin = 1 ; penlen = pen_a.length
      @cook_rendering_proc = -> col_width_a, cols=nil, seplen=nil do
        seplen ||= 0
        render_a = -> do
          my_room = -> do
            pane_width = cols || CLI::Lipstick.cols || default_width[]
            width_before_lipstick = col_width_a.reduce( :+ ) +
              ( [ col_width_a.length - 1, 0 ].max * seplen )
            # minus one because it's a separator, minus one b.c we don't count
            # lipstick, and then plus one for the left margin hack [#fm-008]
            [ min_room,
              ( width_before_lipstick + seplen ) * -1 + pane_width - margin
            ].max
          end.call
          pen_a.map { |p| p.cook my_room }
        end.call
        -> * normalized_float_a do
          penlen == normalized_float_a.length or raise ::ArgumentError,
            "wrong number of arguments #{ normalized_float_a.length } for #{
            }#{ penlen })"
          tot = normalized_float_a.reduce 0.0 do |m, x|
            m + ( x || 0.0 )
          end
          if 0.0 <= tot && tot <= 1.0   # if the sum of your normalized floats
            penlen.times.map do |idx|   # is outside of unit range: NOTHING.
              render_a.fetch( idx ).call normalized_float_a.fetch( idx )
            end * ''
          end
        end
      end
    end
  end
end
