module Skylab::Basic

  class StateMachine  # :[044] (justification at document)

    class << self
      def begin_definition
        DefineStateMachine___.new
      end
    end  # >>

    # ==

    DEFINITION_FOR_THE_METHOD_CALLED_FAIL_BECAUSE_ = -> & p do

      # such a failure is *not* for when an input fails to parse against a
      # grammar. rather, this is for when the grammar itself behaves
      # ambiguously. as such it is not appropriate to "express" such a
      # failure to an end-user but rather we raise an exception the intended
      # audience for which is the developer.
      #
      # because of weak typing and the dynamic nature of state handlers,
      # (which can call any directive(s) and produce any result) we cannot
      # effect such checks until parse-time.

      # (this is #not-covered but the below magnet is)

      _msg = ExpandedBuffer_via_MessageProc_.call_by do |o|  # see
        o.buffer = ""
        o.separator = SPACE_
        o.message_proc = p
        o.session = self
      end

      raise StateMachineBehaviorError, _msg
    end

    # ==

      class DefineStateMachine___

        def initialize

          Home_.lib_.autonomous_component_system
          Assume_ACS_[]

          @_bx = Common_::Box.new
        end

        def add_state * x_a

          x_a.unshift :add, :state

          ACS_.edit x_a, self
        end

        def __state__component_association
          yield :can, :add
          State___
        end

        def __add__component qk, & _x_p
          x = qk.value_x
          if x
            @_bx.add x.name_symbol, x
            x
          else
            x
          end
        end

        # ~ two ways to finish:

        def finish
          StateMachine__.new remove_instance_variable( :@_bx ).freeze
        end
      end

    # =
    # ==

    StateMachine__ = self
    class StateMachine__

      def initialize bx
        @_bx = bx
      end

      def solve_against upstream, & p
        _begin_active_session_by do |o|
          o.downstream = []
          o.upstream = upstream
          o.listener = p
        end.execute
      end

      def solve_into_against downstream, upstream, & p
        _begin_active_session_by do |o|
          o.downstream = downstream
          o.upstream = upstream
          o.listener = p
        end.execute
      end

      def begin_passive_session_by
        as = _begin_active_session_by do |o|
          yield o
        end
        ps = PassiveSession___.new as
        as.page_listener = ps  # ick/meh
        ps
      end

      def begin_driven_session_by
        DrivenSession___.define do |o|
          yield o
          o.active_session = _begin_active_session_by do |as|
            o.define_active_session__ as
          end
        end.execute
      end

      def _begin_active_session_by
        ActiveSession___.define do |o|
          yield o
          o.box = @_bx
        end
      end
    end

    # ==

    class State___  # #testpoint

      class << self

        def interpret_compound_component st
          new do
            @name_symbol = st.gets_one
            process_argument_scanner_passively st
          end
        end

        private :new
      end  # >>

      Attributes_actor_[ self ]

      def initialize & edit_p
        instance_exec( & edit_p )
      end

    private  # -- writers

      def can_transition_to=

        x = gets_one
        a = x.respond_to?( :id2name ) ? [ x ] : x

        if a
          case 1 <=> a.length
          when -1
            @has_at_least_one_formal_transition = true
            @has_more_than_one_formal_transition = true
            @formal_transition_symbol_array = a
          when 0
            @has_at_least_one_formal_transition = true
            @has_exactly_one_formal_transition = true
            @formal_transition_state_symbol = a.fetch 0
          when 1
            @has_at_least_one_formal_transition = false
          end
        else
          @has_at_least_one_formal_transition = false
        end
        KEEP_PARSING_
      end

      def entered_by=
        _accept_barrier_to_entry( & gets_one )
        KEEP_PARSING_
      end

      def entered_by_regex=

        rx = gets_one

        _accept_barrier_to_entry do |st|

          if ! st.no_unparsed_exists
            md = rx.match st.head_as_is
            if md
              st.advance_one
              md
            end
          end
        end

        KEEP_PARSING_
      end

      def _accept_barrier_to_entry & p
        @has_barrier_to_entry = true
        @__barrier_to_entry = p
        NIL_
      end

      def on_entry=
        @has_handler = true
        @_on_entry = gets_one
        KEEP_PARSING_
      end

    public

      # -- readers

      def _user_matchdata_via_upstream us
        @__barrier_to_entry[ us ]
      end

      def next_symbol_via_exposures_proxy___ sm
        @_on_entry[ sm ]
      end

      def description
        _yn1 = has_barrier_to_entry ? 'yes' : 'no'
        _yn2 = has_handler ? 'yes' : 'no'
        "(#{ @name_symbol }: #{ _yn1 } #{ _yn2 })"
      end

      def description_under _expag
        @name_symbol.id2name.gsub UNDERSCORE_, SPACE_
      end

      attr_reader(
        :formal_transition_state_symbol,
        :formal_transition_symbol_array,
        :has_at_least_one_formal_transition,
        :has_exactly_one_formal_transition,
        :has_handler,
        :has_more_than_one_formal_transition,
        :has_barrier_to_entry,
        :name_symbol,
      )
    end

    # ==

    StateMachineBehaviorError = ::Class.new ::RuntimeError

    # ==

    Here_ = self
    STOP_PARSING_ =  NIL

    # ==
  end  # state::machine
end
# #history: a pretty substantial near-rewrite
