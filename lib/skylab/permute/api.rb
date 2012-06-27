require_relative '../../skylab'
require 'skylab/porcelain/bleeding'
require 'skylab/pub-sub/emitter'

module Skylab::Permute
  Bleeding = Skylab::Porcelain::Bleeding
  Porcelain = Skylab::Porcelain
  module API
    module Actions
    end
  end
  class API::Action
    extend Skylab::PubSub::Emitter
  end
  class Permuterator < Enumerator
    def initialize sets
      super() do |y|
        (0...sets.map(&:length).reduce(&:*)).each do |i|
          n = i
          y << (sets.map do |set|
            prev_n = n
            n /= set.length
            [set.sym, set.values[prev_n % set.length]]
          end)
        end
      end
    end
  end
  class API::Actions::Generate < API::Action
    emits :row, :end, :header
    def initialize sets
      @sets = sets
      yield self
    end
    def execute
      emit(:header, sets.map { |s| [s.sym, s.name] })
      Permuterator.new(sets).each { |row| emit(:row, row) } if sets.any?
      emit(:end)
    end
    attr_reader :sets
  end
end

