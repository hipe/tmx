module Skylab::Permute

  module API
  end

  class API::Action
    extend PubSub::Emitter
    event_factory -> _, __, x=nil { x } # "datapoints" - events are just the data
  end

  class Permuterator < ::Enumerator
    def initialize enum_a
      super(  ) do |y|
        ( 0...enum_a.map(& :length ).reduce(& :* ) ).each do |i|
          n = i
          y << ( enum_a.map do |enum|
            prev_n = n
            n /= enum.length
            [ enum.normalized_name, enum.value_a[ prev_n % enum.length ] ]
          end )
        end
      end
    end
  end

  module API::Actions
  end

  class API::Actions::Generate < API::Action

    emits :header, :row, :finished

    def execute

      emit :header, ( @enum_a.map do |e|
        [ e.normalized_name, e.label ]
      end )

      if @enum_a.length.nonzero?
        Permuterator.new( @enum_a ).each do |row|
          emit :row, row
        end
      end

      emit :finished
    end

    attr_reader :enum_a

  protected

    def initialize enum_a
      @enum_a = enum_a
      yield self
    end
  end
end
