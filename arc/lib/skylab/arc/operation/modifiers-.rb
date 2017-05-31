module Skylab::Arc

  module Operation

    module Modifiers_

      # #open [#008.A] imagine ways to make them extensible

      class Parse

        class << self

          def call_via_argument_scanner__ scn
            new.___init_via( scn ).execute
          end

          private :new
        end  # >>

        def ___init_via scn
          @argument_scanner = scn
          self
        end

        def execute

          # assume current argument scanner head is a modifier keyword..

          @struct = Struct___.new

          op_h = OP_H___
          scn = @argument_scanner
          p = op_h.fetch scn.gets_one
          begin
            instance_exec( & p )

            # (because of the imperative phrase grammar,
            # we must have at least one more token:)

            p = op_h[ scn.head_as_is ]
            if p
              scn.advance_one
              redo
            end
            break
          end while nil

          @struct
        end
      end

      o = {}
      members = []

      # -- `assuming` & `if` (conditionals)

      if_or_assuming = -> st do
        if :not == st.head_as_is
          is_negated = true
          st.advance_one
        end
        If_or_Assuming___.new is_negated, st.gets_one
      end

      If_or_Assuming___ = ::Struct.new :is_negated, :symbol

      members.push :assuming
      o[ :assuming ] = -> do
        modz = @struct
        if ! modz.assuming
          modz.assuming = []
        end
        modz.has_conditions = true
        modz.assuming.push if_or_assuming[ @argument_scanner ]
        NIL_
      end

      members.push :has_conditions, :if
      o[ :if ] = -> do
        modz = @struct
        if modz.if
          self._COVER_ME  # this should be disallowed - bool semantics not clear
        end
        modz.has_conditions = true
        modz.if = if_or_assuming[ @argument_scanner ]
        NIL_
      end

      # -- `using`

      members.push :using
      o[ :using ] = -> do
        modz = @struct
        a = modz.using
        if ! a
          a = []
          modz.using = a
        end
        a.push @argument_scanner.gets_one
        NIL_
      end

      # -- `via`

      members.push :via
      o[ :via ] = -> do
        @struct.via = @argument_scanner.gets_one
        NIL_
      end

      Struct___ = ::Struct.new( * members )
      OP_H___ = o
    end
  end
end
