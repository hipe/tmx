module Skylab::Basic

  class StateMachine  # :[044] (justification at document)

    class << self
      def begin_definition
        DefineStateMachine___.new
      end
    end  # >>

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
        begin_session_by do |o|
          o.downstream = []
          o.upstream = upstream
          o.listener = p
        end.execute
      end

      def solve_into_against downstream, upstream, & p
        begin_session_by do |o|
          o.downstream = downstream
          o.upstream = upstream
          o.listener = p
        end.execute
      end

      def begin_session_by
        ActiveSession___.define do |o|
          yield o
          o.box = @_bx
        end
      end

      def begin_passive_session downstream, & p
        sess = PassiveSession___.define do |o|
          o.downstream = downstream
          o.box = @_bx
          o.listener = p
        end
        sess._receive_begin_solution
        sess
      end
    end

    # ==

    class State___

      class << self

        def interpret_compound_component st
          new do
            @name_symbol = st.gets_one
            process_polymorphic_stream_passively st
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

        a = gets_one_polymorphic_value

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
        _accept_barrier_to_entry( & gets_one_polymorphic_value )
        KEEP_PARSING_
      end

      def entered_by_regex=

        rx = gets_one_polymorphic_value

        _accept_barrier_to_entry do |st|

          if ! st.no_unparsed_exists
            md = rx.match st.current_token
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
        @_on_entry = gets_one_polymorphic_value
        KEEP_PARSING_
      end

    public

      # -- readers

      def _user_matchdata_via_upstream us
        @__barrier_to_entry[ us ]
      end

      def __next_symbol_via_nothing
        @_on_entry.call
      end

      def __next_symbol_via_machine_and_user_matchata sm, umd
        @_on_entry[ sm, umd ]
      end

      def description
        _yn1 = has_barrier_to_entry ? 'yes' : 'no'
        _yn2 = has_handler ? 'yes' : 'no'
        "(#{ @name_symbol }: #{ _yn1 } #{ _yn2 })"
      end

      def description_under _expag
        Common_::Name.via_variegated_symbol( @name_symbol ).as_human
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

    Here_ = self
    STOP_PARSING_ =  NIL

    # ==
  end  # state::machine
end
# #history: a pretty substantial near-rewrite
