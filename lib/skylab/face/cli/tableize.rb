module Skylab::Face

  module CLI::Tableize
    # empty
  end

  module CLI::Tableize::InstanceMethods
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
  end
end
