module Skylab::Autonomous_Component_System

  class Parameter

    class Write_Into__via__Argument_Scanner___

      self._HUH?  # #todo

      # when your formal operation defines itself as A) a (presumably
      # [#fi-007] session-like) class, and B) it doesn't specify its own
      # parameters value reader (so it will attempt to parse parameters
      # from the argument stream). one of the permutations of [#028].

      def initialize sess, n11n
        @_n11n = n11n
        @_sess = sess
      end

      def execute

        n11n = @_n11n ; sess = @_sess

        fo_bx = n11n.flush_formals_stream_to_box_

        _h = n11n.parse_from_argument_scanner_into_against_( {}, fo_bx )
        _rdr_p = _h.method :fetch

        _st = fo_bx.to_value_stream

        n11n.normalize_argument_hash_against_stream_ _rdr_p, _st do |x, par|

          sess.send :"#{ par.name_symbol }=", x
        end
      end
    end
  end
end
