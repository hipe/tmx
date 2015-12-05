module Skylab::Autonomous_Component_System

  # ->

    class Parameter  # a fresh take on an old hat

      class << self

        def new_prototype
          new do end
        end

        def collection_into_via_mutable_platform_parameters bx, a

          # every param except any trailing block has an isomorph

          if a.length.nonzero? && :block == a.last.first  # might not be used
            a.pop
          end

          h = bx.h_

          a.each do | cat, sym |
            existing = h[ sym ]
            if existing
              existing.send :"_when__#{ cat }__"
            else
              new do
                bx.add sym, self
                @name_symbol = sym
                send :"_when__#{ cat }__"
              end
            end
          end

          NIL_
        end

        def interpret_into_via_passively_ bx, st

          par = new do
            __init_via_argument_stream_passively st
          end

          bx.add par.name_symbol, par

          NIL_
        end

        private :new
      end  # >>

      def initialize & p

        @takes_argument = true

        instance_exec( & p )
      end

      def __init_via_argument_stream_passively st

        @name_symbol = st.gets_one

        m = :"__interpret__#{ st.gets_one }__"
        begin
          _kp = send m, st
          _kp or fail
          st.no_unparsed_exists and break
          m = :"__interpret__#{ st.current_token }__"
          if respond_to? m
            st.advance_one
            redo
          end
          break
        end while nil

        NIL_
      end

      def mutate_against_polymorphic_stream_passively st

        begin
          st.no_unparsed_exists and break
          m = :"__interpret__#{ st.current_token }__"
          if respond_to? m
            st.advance_one
            _kp = send m, st
            _kp ? redo : break
          end
          break
        end while nil
        NIL_
      end

      # ~ default (experimental)

      def __interpret__default__ st

        x = st.gets_one
        @default_block = -> { x }
        KEEP_PARSING_
      end

      attr_reader(
        :default_block,
      )

      # ~ arities & related

      def __interpret__is_flag__ _
        @takes_argument = false
        KEEP_PARSING_
      end

      def _when__opt__
        @parameter_arity = :zero_or_one
        NIL_
      end

      def _when__req__
        @parameter_arity = :one
        NIL_
      end

      def _when__rest__
        @parameter_arity = :zero_or_more
        NIL_
      end

      attr_reader :takes_argument

      def takes_many_arguments
        :zero_or_more == @parameter_arity
      end

      def argument_is_required
        true
      end

      rx = nil
      define_method :argument_moniker do  # :+[#124]

        rx ||= /\A[^_]+/
        rx.match( @name_symbol )[ 0 ].upcase
      end

      def is_effectively_optional_
        if has_default
          true
        else
          ! is_required
        end
      end

      def is_required
        :one == @parameter_arity
      end

      attr_reader(
        :parameter_arity,  # as [#090]
      )

      # ~ description & name

      def __interpret__description__ st
        @has_description = true
        @_description_block = st.gets_one
        KEEP_PARSING_
      end

      def under_expression_agent_get_N_desc_lines expag, n=nil

        if n

          _p_a = [ @_description_block ]
          Home_.lib_.basic::String::N_Lines[ [], n, _p_a, expag ]
        else
          expag.calculate [], & @_description_block
        end
      end

      def __interpret__name__ st
        @_nf = st.gets_one
        KEEP_PARSING_
      end

      def name
        @_nf ||= Callback_::Name.via_variegated_symbol( @name_symbol )
      end

      attr_reader(
        :has_description,
        :name_symbol,
      )

      # ~ intrinsic reflection (needed by mode clients)

      def has_custom_moniker
        false
      end

      def has_default
        false
      end
    end
  # -
end
