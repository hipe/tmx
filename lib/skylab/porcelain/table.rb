# rewrite as an excercize to be purely event-driven

require File.expand_path('../..', __FILE__)

require 'skylab/pub-sub/emitter'
require 'stringio'

module Skylab::Porcelain
end

module Skylab::Porcelain::Table

  class OnTable < ::Skylab::PubSub::Emitter.new(:all, :info => :all, :empty => :info)
  end

  class << ::Skylab::Porcelain
    def table row_enumerator
      e = OnTable.new
      if block_given?
        yield e
      else
        ret = StringIO.new
        e.on_all { |ev| ret.puts ev }
      end
      cache = []
      row_enumerator.each do |row|
      end
      if cache.size.zero?
        e.emit(:empty, '(empty)')
      end
      ret.string if ret
    end
  end
end

