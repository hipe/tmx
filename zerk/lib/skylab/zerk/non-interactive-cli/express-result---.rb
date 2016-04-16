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
        if @_do_set_exitstatus
          @CLI.init_exitstatus_ 0
        end
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

        @_do_set_exitstatus = true

        x = @x
        if x

          if x.respond_to? :express_into_under
            __prepare_for_expressive
            shape = :expressive

          elsif x.respond_to? :gets
            shape = :streamish

          elsif x.respond_to? :ascii_only?
            shape = :stringish

          elsif x.respond_to? :bit_length
            shape = :intish

          elsif true == x
            self._README  # when true/false, assume it's semantic so
              # *output* "yes"/"no". this has far reaching impact because
              # now we can't result in ACHIEVED_ per our instinct. :#here
          end
          # (else will try custom effection)
        elsif x.nil?
          shape = :nil
        else
          self._README  # :#here
        end

        if shape
          @shape = shape
        else
          __custom_effection_or_bust x
        end
        NIL_
      end

      def __custom_effection_or_bust x

        found = Here_::Custom_Effection___::Find.call x, @CLI

        if found.ok
          @_do_set_exitstatus = false
          @shape = :__custom_effection
          @_custom_effection = found
        else
          raise found.to_exception
        end
      end

      # --

      def _act
        send @shape ; nil
      end

      def __custom_effection

        @_custom_effection.effect_for @x  # result is unreliable but [#037]:#"note 2"
        NIL_
      end

      def __prepare_for_expressive

        @__y = ::Enumerator::Yielder.new do |s|
          @CLI.sout.puts s
        end

        NIL_
      end

      def expressive
        @x.express_into_under @__y, @CLI.expression_agent ; nil
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
