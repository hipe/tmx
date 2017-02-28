module Skylab::Autonomous_Component_System

  class Parameter

    class Platform_Arglist__via__Argument_Scanner___

      self._HUH?  # #todo

      # one of the permutations of [#028]. this one is for the simplest of
      # arrangements: parsing arguments off the argument stream to get them
      # into the proc-like operation.

      # the main "thing" about this techinque is the positionality of the
      # prepared arguments. whether or not an actual argument exists for
      # each formal, that "slot" must be filled with something (`nil` if
      # necessary). and there's globs. theory & limitations discussed at [#029]

      # start with an "empty sparse hash" (with one entry for every formal,
      # whose every value is nil). parse tokens off the head of the argument
      # stream passively in the mannter desribed there.

      def initialize n11n
        @_n11n = n11n
      end

      def execute

        args = []

        @formals_box = @_n11n.flush_formals_stream_to_box_

        h = ___build_empty_sparse_hash

        @_n11n.parse_from_argument_scanner_into_against_ h, @formals_box

        _st = @formals_box.to_value_stream

        _rdr_p = h.method :fetch

        ok = @_n11n.normalize_argument_hash_against_stream_ _rdr_p, _st do |x, par|
          if Field_::Takes_many_arguments[ par ]
            if x
              args.concat x
            end
          else
            args.push x
          end
        end

        if ok
          args
        else
          ok
        end
      end

      def ___build_empty_sparse_hash
        h = {}
        @formals_box.a_.each do |k|
          h[ k ] = nil
        end
        h
      end
    end
  end
end
