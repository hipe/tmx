module Skylab::Face

  CLI::Tableize__ = -> opts, line_p, rows do  # :+#deprecation:until-cull

    # `tableize` has been deprecated (use [#036]). but here's a demo:
    #
    #     y = []
    #     Face_::CLI.tableize(
    #       [ food: 'donuts', drink: 'coffee' ], -> line { y << line } )
    #
    #     y.shift   # => "|   Food  |   Drink |"
    #     y.shift   # => "| donuts  |  coffee |"
    #     y.length  # => 0
    #

      opts = { show_header: true }.merge(opts)
      keys_order = []
      max_h = ::Hash.new { |h, k| keys_order.push(k) ; h[k] = 0 }
      rows.each do |row|
        row.each { |k, v| (l = v.to_s.length) > max_h[k] and max_h[k] = l }
      end
      if opts[:show_header]
        label_p = ->(k) do
          l = k.to_s.gsub( UNDERSCORE_, SPACE_ ).capitalize
          l.length > max_h[k] and max_h[k] = l.length
          l
        end
        rows = [::Hash[ keys_order.map{ |k| [ k, label_p[k] ] } ]] + rows.to_a
      end
      left = '| ' ; sep = '  |  ' ; right = ' |'
      rows.each do |row|
        line_p.call("#{left}#{
          keys_order.map{ |k| "%#{max_h[k]}s" % row[k].to_s }.join(sep)
        }#{right}")
      end
      nil
  end
end
