module Skylab::Basic

  class State  # intro at [#044]

    class Machine

      class Edit_Session

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
          Here_
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

        def flush_to_state_machine
          bx = remove_instance_variable :@_bx
          bx.freeze
          Here_::Machine.new bx
        end

        def flush_to_grammar
          bx = remove_instance_variable :@_bx
          bx.freeze
          Grammar___.new bx
        end
      end
    end

    class Grammar___
      def initialize bx
        @_bx = bx
      end
      def build_state_machine
        Here_::Machine.new @_bx
      end
    end

    Here_ = self
    class Here_

      class << self
        def [] st

          _o = new do
            @name_symbol = st.gets_one
            process_polymorphic_stream_passively st
          end

          Common_::Known_Known[ _o ]
        end

      end  # >>

      Attributes_actor_[ self ]

      def initialize & edit_p
        instance_exec( & edit_p )
      end

      def description
        _yn1 = has_proc_for_determining_entry ? 'yes' : 'no'
        _yn2 = has_proc_for_on_entry ? 'yes' : 'no'
        "(#{ @name_symbol }: #{ _yn1 } #{ _yn2 })"
      end

      def description_under _expag

        Common_::Name.via_variegated_symbol( @name_symbol ).as_human
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
        :has_proc_for_determining_entry,
        :has_proc_for_on_entry,
        :handle_entry,
        :handle_possible_entry,
      )

    private

      def entered_by=
        _accept_entered_by( & gets_one_polymorphic_value )
        KEEP_PARSING_
      end

      def entered_by_regex=

        _RX = gets_one_polymorphic_value

        _accept_entered_by do |st|

          unless st.no_unparsed_exists

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
        @has_proc_for_determining_entry = true
        @handle_possible_entry = p
        NIL_
      end

      def on_entry=
        @has_proc_for_on_entry = true
        @handle_entry = gets_one_polymorphic_value
        KEEP_PARSING_
      end
    end

    class Machine

      def initialize bx
        @_bx = bx
      end

      def against upstream_x, * x_a, & x_p
        sess = Active_Session__.new( * x_a, & x_p )
        sess.box = @_bx
        sess.upstream = upstream_x
        sess.execute
      end

      def begin * x_a, & x_p
        sess = Passive_Session___.new( * x_a, & x_p )
        sess.box = @_bx
        sess._receive_begin
        sess
      end
    end

    Session__ = ::Class.new

    class Active_Session__ < Session__

      attr_writer :upstream

      def _receive_begin
        super

        @_step_via_find_entry = method :_step_via_find_entry
        @_step_via_matched_state = method :_step_via_matched_state
        @__step_via_not_yet_matched_state = method :__step_via_not_yet_matched_state

        @_step_p = @_step_via_find_entry
        NIL_
      end

      def execute

        _receive_begin

        st = Common_.stream do
          @_step_p[]
        end

        begin
          _sym = st.gets
          _sym or break
          redo
        end while nil

        @_result
      end

      def _via_found_state_for_transition yes_x, sta
        @_step_p = @_step_via_matched_state
        super
      end

      def _receive_next_state sta

        @_step_p = if sta.has_proc_for_determining_entry

          @__step_via_not_yet_matched_state
        else
          @_step_via_find_entry
        end
        super
      end

      def _receive_ending_state sta

        @_step_p = EMPTY_P_
        super
      end
    end

    class Passive_Session___ < Session__

      def _receive_begin
        @upstream = Passive_Upstream_Proxy___.new
        super
      end

      def puts line

        @upstream.replace line

        _ok = _step_via_find_entry
        if _ok
          __passive_loop
        else
          raise __build_common_exception
        end
      end

      def __build_common_exception
        _build_exception_around _to_possible_next_state_stream.to_a
      end

      def __passive_loop

        begin

          _ok = _step_via_matched_state
          if _ok

            if @_state.has_proc_for_on_entry

              _x = @_state.handle_entry[]
              self._COVER_ME
            end

            break
          end
          self._FUU
        end while nil
        NIL_
      end

      def __step_via_matched_state_that_has_no_on_entry_proc

        # exerimentally we stay..
        @_state.name_symbol
      end
    end

    class Session__

      def initialize ds=[], & x_p

        @_downstream = ds
        @_oes_p = x_p
      end

      attr_writer :box

      def _receive_begin
        @_state = @box.fetch :beginning
        NIL_
      end

      def _step_via_matched_state  # must change state

        sta = @_state

        if sta.has_proc_for_on_entry

          had_proc_for_on_entry = true
          sym = sta.handle_entry[ @_downstream, @_yes_x ]

        end

        if :ending == sta.name_symbol

          sym and self._SANITY

          _receive_ending_state sta

          NIL_  # will break out of the loop

        elsif had_proc_for_on_entry

          if sym
            _receive_next_state @box.fetch sym
            sym
          else
            self._MISBEHAVED_STATE_MACHINE
          end
        else
          __step_via_matched_state_that_has_no_on_entry_proc  # ..
        end
      end

      def _step_via_find_entry

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

        if sta
          _via_found_state_for_transition yes_x, sta
        else
          __when_no_available_transition
        end
      end

      def _via_found_state_for_transition yes_x, sta

        _accept_state sta
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

      def _receive_ending_state sta

        _receive_next_state = sta

        @_result = remove_instance_variable :@_downstream
        NIL_
      end

      def _receive_next_state sta

        _accept_state sta
        NIL_
      end

      def _accept_state sta
        @_state = sta
        NIL_
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
          self._COVER_ME
        end

        NIL_
      end

      def __when_no_available_transition

        _maybe_send_no_available_transition_among(
          _to_possible_next_state_stream.to_a )
      end

      def _maybe_send_no_available_transition_among sta_a  # must result in nil

        if @_oes_p
          @_oes_p.call :error, :case, :no_available_state_transition do
            _build_no_available_transition sta_a
          end
          @_result = UNABLE_
          NIL
        else
          raise _build_exception_around sta_a
        end
      end

      def _build_exception_around sta_a

        _build_no_available_transition( sta_a ).to_exception
      end

      def _build_no_available_transition sta_a

        if @upstream.no_unparsed_exists
          had_more = false
        else
          had_more = true
          x = @upstream.current_token
        end

        Here_::Events_::No_Available_State_Transition.new_with(
          :x, x,
          :had_more, had_more,
          :possible_state_array, sta_a,
        )
      end

      def _to_possible_next_state_stream

        sta = @_state

        if sta.can_transition

          _sym_a = if sta.can_transition_to_exactly_one_state

            [ sta.can_transition_to_state_symbol ]
          else

            sta.can_transition_to_state_symbol_array
          end

          Common_::Stream.via_nonsparse_array _sym_a do | sym |
            @box.fetch sym
          end
        else

          Common_::Stream.the_empty_stream
        end
      end
    end

    class Passive_Upstream_Proxy___  # (mentors something in [pa])

      def current_token
        @current_token
      end

      def replace line
        @current_token = line
        NIL_
      end

      def unparsed_exists
        true
      end

      def advance_one
        if @current_token
          @current_token = nil
        else
          self._COVER_ME
        end
      end
    end
  end
end
