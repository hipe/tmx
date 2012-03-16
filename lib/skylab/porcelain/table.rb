# rewrite as an excercize to be purely event-driven

require File.expand_path('../..', __FILE__)

require 'skylab/pub-sub/emitter'

module Skylab::Porcelain
end

module Skylab::Porcelain::Table

  class OnTable < ::Skylab::PubSub::Emitter.new(:all, :info => :all, :empty => :info)
  end

  class << ::Skylab::Porcelain
    def Table row_enumerator
      yield(e = OnTable.new)
      cache = []
      row_enumerator.each do |row|
      end
      if cache.size.zero?
        e.emit(:empty, '(empty)')
      end
    end
  end
end

