module Skylab::Face

  class CLI::Table

    o = { }

    # `tablify` is a quick & dirty pretty table hack
    #
    # (`curry` friendly (was [#048])
    #
    # like so:
    #
    #     y = [ ]
    #
    #     Face::CLI::Table::FUN.tablify[
    #       [[ :fields, [ 'food', 'drink']],
    #        [ :show_header, true ]],
    #       -> line { y << line },
    #       [[ 'donuts', 'coffee' ]]]
    #
    #     y.shift  # => '|    food |   drink |'
    #     y.shift  # => '|  donuts |  coffee |'
    #     y.length # => 0
    #

    o[:tablify] = -> do
      struct = ::Struct.new :left, :sep, :right, :fields, :show_header
      d =        struct.new '|  ',  ' |  ',  ' |'
      parse_opts = -> opt_a do
        i = nil ; o = struct.new ; opt_a = opt_a ? opt_a.dup : [ ]
        while opt_a.length.nonzero?
          opt = opt_a.shift
          i = opt.fetch( 0 ) ; opt.shift ;  v = opt.fetch( 0 ) ; opt.shift
          o[ i ] = v
        end
        [ o.left || d[:left], o.sep || d[:sep], o.right || d[:right],
          o.fields, o.show_header ]
      end
      -> option_a, output_p, row_ea do # (curry friendly)
        left, sep, right, fields, show_header = parse_opts[ option_a ]
        w = fields.length ; labels = fields
        max_h = ::Hash.new { |h, k| h[ k ] = 0 }
        max = -> a do
          w.times do |x|
            ( l = a.fetch( x ).length ) > max_h[ x ] and max_h[ x ] = l
          end
        end
        show_header and max[ labels ]
        # lock down `row_ea` now - it might be an enumerator that is a
        # randomized functional tree, e.g
        cache_a = [ ] ; ok = row_ea.each do |a|
          cache_a << a
          max[ a ]
        end
        ok or break ok
        fmt = "#{ left }#{ w.times.map do |x|
          "%#{ max_h.fetch x }s"
        end * sep }#{ right }"
        row = -> a { output_p[ fmt % a ] }
        show_header and row[ labels ]
        cache_a.each( & row )
        ok
      end
    end.call

    FUN = ::Struct.new( * o.keys ).new( * o.values )

  end
end
