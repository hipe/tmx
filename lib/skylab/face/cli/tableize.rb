class Skylab::Face::Cli
  module Tableize
    extend self
    def tableize rows, out, opts = {}
      keys_order = []
      max_width = Hash.new { |h, k| keys_order.push(k); h[k] = 0; }
      row_keys = nil # for now
      rows.each do |row|
        (row_keys || row.keys).each do |key|
          row[key].to_s.length > max_width[key] and max_width[key] = row[key].to_s.length
        end
      end
      if (opts.key?(:show_header) ? opts[:show_header] : true)
        label = lambda do |k|
          _label = k.to_s.sub('_', ' ').capitalize
          max_width[k] < _label.length and max_width[k] = _label.length
          _label
        end
        header_row = Hash[ * keys_order.map{ |k| [ k, label[k] ] }.flatten ]
        use_rows = [header_row] + rows
      else
        use_rows = rows
      end
      left = '| '; sep = '  |  '; right = ' |'
      use_rows.each do |row|
        cels = keys_order.map do |key|
          "%#{max_width[key]}s" % row[key].to_s
        end
        out.puts "#{left}#{cels.join(sep)}#{right}"
      end
      nil
    end
  end
end
