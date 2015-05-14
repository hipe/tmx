module Skylab::Permute

  API = ::Module.new

  class API::Action
    Callback_[ self, :employ_DSL_for_digraph_emitter ]

    def build_digraph_event x, _i, _esg
      x
    end
  end

  class Permuterator < ::Enumerator
    def initialize enum_a
      super(  ) do |y|
        ( 0...enum_a.map(& :length ).reduce(& :* ) ).each do |i|
          n = i
          y << ( enum_a.map do |enum|
            prev_n = n
            n /= enum.length
            [ enum.local_normal_name, enum.value_a[ prev_n % enum.length ] ]
          end )
        end
      end
    end
  end

  module API::Actions
  end

  class API::Actions::Generate < API::Action

    listeners_digraph  :header, :row, :finished

    def execute

      call_digraph_listeners :header, ( @enum_a.map do |e|
        [ e.local_normal_name, e.label ]
      end )

      if @enum_a.length.nonzero?
        Permuterator.new( @enum_a ).each do |row|
          call_digraph_listeners :row, row
        end
      end

      call_digraph_listeners :finished
    end

    attr_reader :enum_a

  private

    def initialize enum_a
      @enum_a = enum_a
      yield self
    end
  end
end
