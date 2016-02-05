module Skylab::Autonomous_Component_System

  class Parameter

    class Write_Into__via__Parameters_Reader___

      # more or less just here to implement [ze]-style parameter assembly
      # (which is more-or-less [#027]). one of the permutations of [#028].

      def initialize sess, n11n
        @_n11n = n11n
        @_sess = sess
      end

      def execute

        n11n = @_n11n ; sess = @_sess

        _st = n11n.release_formals_stream_

        _rdr = n11n.release_parameters_value_reader__

        hrdr = _rdr.to_hot_reader__( & sess.handle_event_selectively_for_ACS )

        _rdr_p = -> k, & else_p do

          kn = hrdr.read_value_via_symbol__ k

          if kn.is_known_known
            kn.value_x
          else
            else_p[]
          end
        end

        n11n.normalize_argument_hash_against_stream_ _rdr_p, _st do |x, par|

          sess.send :"#{ par.name_symbol }=", x
        end
      end
    end
  end
end
