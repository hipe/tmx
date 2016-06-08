module Skylab::System

  module Doubles::Stubbed_System

    class Inline_Static_Based

      def initialize
        @_h = {}
      end

      def _add_entry_ chdir=nil, cmd_s_a, & three_p

        _bx = @_h.fetch chdir do
          @_h[ chdir ] = Common_::Box.new
        end

        _bx.add cmd_s_a, Here_::Popen3_Result_via_Proc_.new( & three_p )

        NIL_
      end

      def popen3 * cmd_s_a

        block_given? and raise ::ArgumentError  # no

        if cmd_s_a.last.respond_to? :each_pair
          _key = cmd_s_a.pop.fetch :chdir
        end

        _bx = @_h.fetch _key

        _rslt = _bx.fetch cmd_s_a

        _rslt.produce
      end
    end
  end
end
