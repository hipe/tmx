module Skylab::Face

  module CLI::Tableize
    # empty
  end

  module CLI::Tableize::InstanceMethods

    # `tableize` - deprecated for `tablify`

    def tableize rows, opts = {}, &line_f
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

    # `tablify` - quick & dirty pretty table hack. NOTE `false` below..

    def tablify col_a, row_ea, line, show_header=true, left = '| ',
        sep = '  |  ', right = ' |'

      w = col_a.length
      max_h = ::Hash.new { |h, k| h[ k ] = 0 }
      max = -> *a do
        w.times do |x|
          l = a.fetch( x ).to_s.length
          l > max_h[ x ] and max_h[ x ] = l
        end
      end
      max[ *col_a ] if show_header
      ok = row_ea.each( & max )
      if ok
        fmt = "#{ left }#{ w.times.map do |x|
          "%#{ max_h.fetch x }s"
        end * sep }#{ right }"

        row = -> * a do
          line.call( fmt % a )
        end
        row[ * col_a ] if show_header
        row_ea.each( & row )
      end
      ok
    end
  end
end
