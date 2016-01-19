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

        @argument_arity = :one

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

      # -- #[#fi-010]

      def __interpret__description__ st
        @description_proc = st.gets_one
        KEEP_PARSING_
      end

      attr_reader :description_proc

      rx = nil
      define_method :option_argument_moniker do  # #[#br-124]

        rx ||= /\A[^_]+/
        rx.match( @name_symbol )[ 0 ].upcase
      end

      def argument_argument_moniker  # play along w/ [br] experiment for now
        NIL_
      end

      def __interpret__name__ st
        @_nf = st.gets_one
        KEEP_PARSING_
      end

      def name
        @_nf ||= Callback_::Name.via_variegated_symbol( @name_symbol )
      end

      attr_reader(
        :name_symbol,
      )

      def __interpret__default__ st

        x = st.gets_one
        @default_proc = -> { x }
        KEEP_PARSING_
      end

      attr_reader(
        :default_proc,
      )

      def __interpret__is_flag__ _
        @argument_arity = :zero
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

      attr_reader(
        :parameter_arity,
        :argument_arity,
      )
    end
  # -
end
