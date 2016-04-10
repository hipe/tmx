module Skylab::Zerk

  class NonInteractiveCLI

    class Express_Result___ < Callback_::Actor::Dyadic

      # implement (near) [#025] - a modality-specific result interpretation:

      # if you raise exceptions in your operation, that's on you. we do not
      # (and will not ever in this major version) provide interpretation of
      # or handling for them.

      # how we interpret the result from the operation is up to us, but note
      # there is no modality-agnostic API governing semantics to be applied
      # to the operation result.

      # in adherence to [#ac-002]#DT2 modal dynamicism, we must not apply
      # and modality-specific interpretations of these results either.
      # (that is, we cannot specify our own special API for how results are
      # are to be interpreted and expressed in this modality in any way that
      # would detract from their own inherent, intuitive expressiveness.
      # that is, we cannot decide that integers mean exitstatuses, for
      # example.)

      # assuming [#026] we can at least assume that no error was emitted
      # during the execution of the operation.

      def initialize x, cli
        @x = x
        @CLI = cli
      end

      def execute
        _determine_strategy
        _act
        NIL_
      end

    private

      def streamish
        st = @x
        x = st.gets
        if x
          @x = x
          _determine_strategy
          begin
            _act
            @x = st.gets
            @x or break
            redo
          end while nil
        else
          self._COVER_ME_empty_list
        end
        NIL_
      end

      def _determine_strategy
        x = @x
        @shape = if x

          if x.respond_to? :express_into_under
            :expressive

          elsif x.respond_to? :gets
            :streamish

          elsif x.respond_to? :ascii_only?
            :stringish

          elsif x.respond_to? :bit_length
            :intish
          else

            self._README
            # when true, assume it's semantic, so output "yes" or "no" etc
          end
        elsif x.nil?
          :nil
        else
          self._README
        end
        NIL_
      end

      def _act
        send @shape ; nil
      end

      def expressive
        @x.express_into_under @CLI.sout, @CLI.expression_agent ; nil
      end

      def stringish
        @CLI.sout.puts @x ; nil
      end

      def intish
        @CLI.sout.puts "#{ @x }" ; nil
      end

      def nil
        NOTHING_
      end
    end
  end
end
