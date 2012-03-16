# rewrite as an excercize to be purely event-driven

require File.expand_path('../..', __FILE__)

require 'skylab/pub-sub/emitter'
require 'stringio'

module Skylab::Porcelain
end

module Skylab::Porcelain::Table

  class OnTable < ::Skylab::PubSub::Emitter.new(:all, :info => :all,
    :empty => :info, :row => :all)
  end

  class << ::Skylab::Porcelain
    def table row_enumerator
      head = '' ; tail = '' ; separator = ' '
      e = OnTable.new
      if block_given? then yield(e) else
        ret = StringIO.new
        e.on_all { |ev| ret.puts ev }
      end
      cache = []
      widths = []
      row_enumerator.each do |col_enumerator|
        cache.push(row_cache = [])
        col_enumerator.each_with_index do |col, idx|
          widths[idx].nil? || widths[idx] < col.length and widths[idx] = col.length
          row_cache.push col
        end
      end
      if cache.size.zero?
        e.emit(:empty, '(empty)')
      else
        format = "#{head}#{widths.map.with_index{ |w, i| "%#{w || 0}s" }.join(separator)}#{tail}"
        nerp = widths.size.zero? ? [] : (0..(widths.size - 1)).to_a
        cache.each { |row| e.emit(:row, format % nerp.map { |idx| row[idx] }) }
      end
      ret.string if ret
    end
  end
end

