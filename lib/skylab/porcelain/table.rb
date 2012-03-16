# rewrite as an excercize to be purely event-driven

# issues / wishlist:
#
#   * left/right alignment config options

require File.expand_path('../..', __FILE__)

require 'skylab/pub-sub/emitter'
require 'stringio'

module Skylab::Porcelain
end

module Skylab::Porcelain::Table

  class OnTable < Struct.new(:head, :tail, :separator)
    extend ::Skylab::PubSub::Emitter
    emits(:all, :info => :all,
      :empty => :info, :row => :all)
  end

  class << ::Skylab::Porcelain
    def table row_enumerator, opts=nil
      o = OnTable.new
      opts and opts.each { |k, v| o.send("#{k}=", v) }
      if block_given? then yield(o) else
        ret = StringIO.new
        o.on_all { |ev| ret.puts ev }
      end
      o.head ||= '' ; o.tail ||= '' ; o.separator ||= ' '
      cache = []
      widths = []
      row_enumerator.each do |col_enumerator|
        cache.push(row_cache = [])
        col_enumerator.each_with_index do |col, idx|
          widths[idx].nil? || widths[idx] < col.length and widths[idx] = col.length
          row_cache.push col
        end
      end
      if cache.size.zero? then o.emit(:empty, '(empty)') else
        format = "#{o.head}#{widths.map.with_index{ |w, i| "%#{w || 0}s" }.join(o.separator)}#{o.tail}"
        nerp = widths.size.zero? ? [] : (0..(widths.size - 1)).to_a
        cache.each { |row| o.emit(:row, format % nerp.map { |idx| row[idx] }) }
      end
      ret.string if ret
    end
  end
end

