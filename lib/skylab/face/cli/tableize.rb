module Skylab::Face

  module CLI::Tableize

    # `tableize` - deprecated for `tablify` [#fa-036]
    #
    # `tableize` has been deprecated for `tablify`. but here's a demo:
    #
    #     y = [ ]
    #     Face::CLI::Tableize::FUN.tableize[
    #       [ food: 'donuts', drink: 'coffee' ], -> line { y << line } ]
    #
    #     y.shift   # => "|   Food  |   Drink |"
    #     y.shift   # => "| donuts  |  coffee |"
    #     y.length  # => 0
    #

    o = { }

    o[:tableize] = ->( rows, opts = {}, f, &blk) do
      line_f = ( a = [ f, blk ].compact ).fetch( ( a.length - 1 ) * 2 )
      opts = { show_header: true }.merge(opts)
      keys_order = []
      max_h = ::Hash.new { |h, k| keys_order.push(k) ; h[k] = 0 }
      rows.each do |row|
        row.each { |k, v| (l = v.to_s.length) > max_h[k] and max_h[k] = l }
      end
      if opts[:show_header]
        label_f = ->(k) do
          l = k.to_s.gsub('_', ' ').capitalize
          l.length > max_h[k] and max_h[k] = l.length
          l
        end
        rows = [::Hash[ keys_order.map{ |k| [ k, label_f[k] ] } ]] + rows.to_a
      end
      left = '| ' ; sep = '  |  ' ; right = ' |'
      rows.each do |row|
        line_f.call("#{left}#{
          keys_order.map{ |k| "%#{max_h[k]}s" % row[k].to_s }.join(sep)
        }#{right}")
      end
      nil
    end

    # `tablify` - quick & dirty pretty table hack.  NOTE `false` below..
    #
    # (if `row_ea` is an enumerator we've got to lock it down .. it might
    # be a randomized functional tree, e.g)
    #
    # usage:
    #
    #     y = [ ]
    #     Face::CLI::Tableize::FUN.tablify[
    #       [ 'food', 'drink' ],
    #       [[ 'donuts', 'coffee' ]], -> line { y << line } ]
    #
    #     y.shift  # => '|   food  |   drink |'
    #     y.shift  # => '| donuts  |  coffee |'
    #     y.length # => 0
    #

    o[:tablify] = -> col_a, row_ea, line, show_header=true, left = '| ',
        sep = '  |  ', right = ' |' do

      w = col_a.length
      max_h = ::Hash.new { |h, k| h[ k ] = 0 }
      max = -> a do
        w.times do |x|
          l = a.fetch( x ).length
          l > max_h[ x ] and max_h[ x ] = l
        end
      end
      max[ col_a ] if show_header
      cache_a = []
      ok = row_ea.each do |a|
        cache_a << a
        max[ a ]
      end
      if ok
        fmt = "#{ left }#{ w.times.map do |x|
          "%#{ max_h.fetch x }s"
        end * sep }#{ right }"
        row = -> * a do
          line.call( fmt % a )
        end
        row[ * col_a ] if show_header
        cache_a.each do |a|
          row[ *a ]
        end
      end
      ok
    end

    FUN = ::Struct.new( * o.keys ).new( * o.values )

    module InstanceMethods
      define_method :tableize, & FUN.tableize
      define_method :tablify, & FUN.tablify
    end
  end
end
