module Skylab::Autonomous_Component_System
  # ->
    class Parameter  # :[#020] (compare to and stay close to [#fi-039] defined attribute)

      class << self

        def new_prototype
          new do end
        end

        def new_prototype_by__ & p
          new( & p )
        end

        def interpret_into_via_passively__ bx, st

          par = new do
            __init_via_argument_stream_passively st
          end

          bx.add par.name_symbol, par

          NIL_
        end

        alias_method :new_by_, :new
        private :new
      end  # >>

      def initialize & p
        @argument_arity = :one
        instance_exec( & p )
      end

      # --

      def dup_by & p
        o = dup
        o.instance_exec( & p )
        o
      end

      private :dup

      def name= x
        @name = x
      end

      # --

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
        @name = st.gets_one
        KEEP_PARSING_
      end

      def name
        @name ||= Common_::Name.via_variegated_symbol @name_symbol
      end

      def name_symbol
        @name_symbol
      end

      def __interpret__default__ st

        x = st.gets_one
        @default_proc = -> { x }
        KEEP_PARSING_
      end

      def __interpret__default_proc__ st

        @default_proc = st.gets_one
        KEEP_PARSING_
      end

      attr_reader(
        :default_proc,
      )

      def __interpret__optional__ _
        @parameter_arity = :zero_or_one
        KEEP_PARSING_
      end

      def __interpret__is_flag__ _
        @parameter_arity = :zero_or_one
        @argument_arity = :zero
        KEEP_PARSING_
      end

      attr_reader(
        :parameter_arity,
        :argument_arity,
      )

      def is_probably_the_singularest  # ..
        true
      end

      Here_ = self
    end
  # -
end
