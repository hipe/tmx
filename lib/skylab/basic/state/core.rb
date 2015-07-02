module Skylab::Basic

  class State  # intro at [#044]

    class Machine

      class Edit_Session

        def initialize
          @_bx = Callback_::Box.new
        end

        def add_state * x_a

          x_a.unshift :add, :state
          Home_.lib_.brazen::Mutation_Session.edit x_a, self
        end

        def self.__state__association_for_mutation_session
          State_
        end

        def mutable_body_for_mutation_session
          self
        end

        def __add__object_for_mutation_session x
          if x
            @_bx.add x.name_symbol, x
            ACHIEVED_
          else
            x
          end
        end

        def receive_changed_during_mutation_session
          ACHIEVED_
        end

        def build_state_machine

          bx = @_bx
          @_bx = nil
          Machine___.new bx.freeze
        end
      end

      Machine___ = self
    end

    State_ = self
    class State_

      class << self
        def [] st

          _o = new do
            @name_symbol = st.gets_one
            process_polymorphic_stream_passively st
          end

          Callback_::Pair.new _o
        end

      end  # >>

      Callback_::Actor.methodic self

      def initialize & edit_p
        instance_exec( & edit_p )
      end

      def description_under _expag

        Callback_::Name.via_variegated_symbol( @name_symbol ).as_human
      end

      attr_reader :name_symbol

      attr_reader(
        :can_transition,
        :can_transition_to_exactly_one_state,
        :can_transition_to_more_than_one_state,
        :can_transition_to_state_symbol,
        :can_transition_to_state_symbol_array,
      )

    private

      def can_transition_to=

        a = gets_one_polymorphic_value

        if a
          case 1 <=> a.length
          when -1
            @can_transition = true
            @can_transition_to_more_than_one_state = true
            @can_transition_to_state_symbol_array = a
          when 0
            @can_transition = true
            @can_transition_to_exactly_one_state = true
            @can_transition_to_state_symbol = a.fetch 0
          when 1
            @can_transition = false
          end
        else
          @can_transition = false
        end
        KEEP_PARSING_
      end

    public

      attr_reader(
        :has_proc_for_entry,
        :handle_possible_entry,
        :handle_entry,
      )

    private

      def entered_by=
        _accept_entered_by( & gets_one_polymorphic_value )
        KEEP_PARSING_
      end

      def entered_by_regex=
        _RX = gets_one_polymorphic_value
        _accept_entered_by do | st |

          if st.unparsed_exists

            md = _RX.match st.current_token
            if md
              st.advance_one
              md
            end
          end
        end
        KEEP_PARSING_
      end

      def _accept_entered_by & p
        @has_proc_for_entry = true
        @handle_possible_entry = p
        NIL_
      end

      def on_entry=
        @handle_entry = gets_one_polymorphic_value
        KEEP_PARSING_
      end
    end

    class Machine

      def initialize bx
        @_bx = bx
      end

      def against upstream_x, & x_p
        sess = Session___.new( & x_p )
        sess.box = @_bx
        sess.upstream = upstream_x
        sess.execute
      end
    end

    class Session___

      def initialize & x_p

        @_downstream = []  # for now
        @_oes_p = x_p
      end

      attr_writer :box, :upstream

      def execute

        @_state = @box.fetch :beginning

        @_step_via_find_next_state = method :_step_via_find_next_state
        @_step_via_matched_state = method :_step_via_matched_state
        @__step_via_not_yet_matched_state = method :__step_via_not_yet_matched_state

        @_step_p = @_step_via_find_next_state

        st = Callback_.stream do
          @_step_p[]
        end

        begin
          _sym = st.gets
          _sym or break
          redo
        end while nil

        @_user_x
      end

      def _step_via_find_next_state

        st = _to_possible_next_state_stream

        begin

          sta = st.gets
          sta or break

          yes_x = sta.handle_possible_entry[ @upstream ]
          if yes_x
            break
          end

          redo
        end while nil

        __via_any_found_state_for_transistion yes_x, sta
      end

      def __via_any_found_state_for_transistion yes_x, sta

        if sta
          __via_found_state_for_transition yes_x, sta
        else
          __when_no_available_transition
        end
      end

      def __via_found_state_for_transition yes_x, sta

        @_state = sta
        @_step_p = @_step_via_matched_state
        @_yes_x = yes_x

        sta.name_symbol
      end

      def __step_via_not_yet_matched_state

        yes_x = @_state.handle_possible_entry[ @upstream ]

        if yes_x
          @_yes_x = yes_x
          _step_via_matched_state

        else

          _maybe_send_no_available_transition_among [ @_state ]
        end
      end

      def _step_via_matched_state  # must change step

        sta = @_state

        if sta.has_proc_for_entry

          sym = sta.handle_entry[ @_downstream, @_yes_x ]

        end

        if :ending == sta.name_symbol

          sym and self._SANITY

          @_step_p = EMPTY_P_

          @_user_x = @_downstream
          @_downstream = nil

          NIL_  # will break out of the loop
        else

          sym or self._SANTIY

          sta_ = @box.fetch sym

          @_state = sta_

          @_step_p = if sta_.has_proc_for_entry

            @__step_via_not_yet_matched_state
          else
            @_step_via_find_next_state
          end

          sym
        end
      end

      def _via_state_reinit_proc

        sta = @_state

        if sta.can_transition
          if sta.can_transition_to_more_than_one_state
            @_p = @__step_via_multi_state
          else
            @_p = @__step_via_single_state
          end
        else
          self._K
        end

        NIL_
      end

      def __when_no_available_transition

        _maybe_send_no_available_transition_among(
          _to_possible_next_state_stream.to_a )
      end

      def _maybe_send_no_available_transition_among sta_a  # must result in nil

        if @upstream.unparsed_exists
          had_more = true
          x = @upstream.current_token
        else
          had_more = false
        end

        @_user_x = @_oes_p.call :error, :case, :no_available_state_transition do

          State_::Events_::No_Available_State_Transition.new_with(
            :x, x, :had_more, had_more, :possible_state_array, sta_a )
        end

        NIL_
      end

      def _to_possible_next_state_stream

        sta = @_state

        if sta.can_transition

          _sym_a = if sta.can_transition_to_exactly_one_state

            [ sta.can_transition_to_state_symbol ]
          else

            sta.can_transition_to_state_symbol_array
          end

          Callback_::Stream.via_nonsparse_array _sym_a do | sym |
            @box.fetch sym
          end
        else

          Callback_::Stream.the_empty_stream
        end
      end
    end
  end
end
