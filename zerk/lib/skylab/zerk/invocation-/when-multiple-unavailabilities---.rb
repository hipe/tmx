module Skylab::Zerk

  module Invocation_

    class When_multiple_unavailabilities___ < Callback_::Actor::Dyadic

      def initialize unava_p_a, asc
        @assoc = asc
        @unava_p_a = unava_p_a
      end

      def execute
        method :___build_tuple
      end

      def ___build_tuple

        asc = @assoc ; unava_p_a = @unava_p_a

        _ev_p = -> y do

          o = Home_.lib_.basic::Yielder::Mapper.new

          o.downstream_yielder = y

          o.map_first_by do |s|
            "  • #{ s }"
          end

          o.map_subsequent_by do |s|
            "    #{ s }"
          end

          y << "#{ nm asc.name } is not available because:"

          unava_p_a.each do |p|
            (*sym_a, ev_p_) = p[]
            :expression == sym_a[ 1 ] or self._HELL_NO
            o.reset
            calculate o.y, & ev_p_
          end

          y
        end

        _which = if 1 == unava_p_a.length
          :required_component_not_present
        else
          :required_components_not_present
        end

        [ :error, :expression, _which, _ev_p ]
      end
      # -
    end
  end
end
# #open [#024] redundancy