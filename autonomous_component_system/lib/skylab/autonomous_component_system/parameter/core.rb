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

        def interpret_into_via_passively__ bx, scn

          par = new do
            __init_via_argument_scanner_passively scn
          end

          bx.add par.name_symbol, par

          NIL_
        end

        alias_method :new_by_, :new
        private :new
      end  # >>

      def initialize & p
        @argument_arity = :one  # "most" are this
        @parameter_arity = :one  # "most" are this
        instance_exec( & p )
      end

      # -- dup-and-mutate

      def dup_by
        o = dup
        yield o
        o
      end

      private :dup

      attr_writer(
        :argument_arity,
        :name,
      )

      # --

      def __init_via_argument_scanner_passively scn

        @name_symbol = scn.gets_one

        m = :"__interpret__#{ scn.gets_one }__"
        begin
          _kp = send m, scn
          _kp or fail
          scn.no_unparsed_exists and break
          m = :"__interpret__#{ scn.head_as_is }__"
          if respond_to? m
            scn.advance_one
            redo
          end
          break
        end while nil

        NIL_
      end

      def mutate_against_argument_scanner_passively scn

        begin
          scn.no_unparsed_exists and break
          m = :"__interpret__#{ scn.head_as_is }__"
          if respond_to? m
            scn.advance_one
            _kp = send m, scn
            _kp ? redo : break
          end
          break
        end while nil
        NIL_
      end

      # -- #[#fi-010]

      def __interpret__description__ scn
        @description_proc = scn.gets_one
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

      def __interpret__name__ scn
        @name = scn.gets_one
        KEEP_PARSING_
      end

      def name
        @name ||= Common_::Name.via_variegated_symbol @name_symbol
      end

      def name_symbol
        @name_symbol
      end

      def __interpret__default__ scn

        x = scn.gets_one
        @default_proc = -> { x }
        KEEP_PARSING_
      end

      def __interpret__default_proc__ scn

        @default_proc = scn.gets_one
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

      # -- see #note-1 and #note-2 in [#026]

      def singplur_category_of_association
        NOTHING_
      end

      def is_provisioned  # currently a [ze] thing
        false
      end

      def parameter_arity_is_known
        TRUE  # always, here
      end

      Autoloader_[ self ]
      stowaway(
        :AssociationIndex_via_PlatformParameters_and_FormalOperation,
        'formal-parameter-stream-via-platform-parameters-and-formal-operation'
      )  # while #pending-rename

      Here_ = self
    end
  # -
end
