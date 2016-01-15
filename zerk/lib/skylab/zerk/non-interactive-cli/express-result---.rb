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
        @cli = cli
      end

      def execute
        x = @x
        if x
          if true == x
            # let's assume it's semantic true, so we want to output "yes" or etc.
            self._WHEN_TRUE
          elsif x.respond_to? :bit_length
            @cli.sout.puts "#{ x }"
          else
            self._TRUEISH_OTHER  # eventually we will want to call [#br-068]
          end
        elsif x.nil?
          # it seems reasonable to interpret nil as "nothing"
        else
          self._WHEN_FALSE
        end
        NIL_
      end
    end
  end
end
