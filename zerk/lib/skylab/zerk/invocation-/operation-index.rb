module Skylab::Zerk

  module Invocation_

    class Operation_Index  # 1x. notes in [#013]

      # (we don't know yet how public this will need to be..)

      class << self

        def for_top_ sb, pbc
          _begin_empty.__index_for_top sb, pbc
        end

        alias_method :_begin_empty, :new
        undef_method :new
      end  # >>

      def dup_for_recursion__ pbc
        self.class._begin_empty.___init_as_recurse pbc, self
      end

      def ___init_as_recurse pbc, otr

        @formal_operation = pbc.formal_operation
        @procure_bound_call_ = pbc
        @scope_index_ = otr.scope_index_
        __partition_as_recurse
        self
      end

      def __index_for_top sb, pbc

        @formal_operation = pbc.formal_operation
        @procure_bound_call_ = pbc
        @scope_index_ = Here_::Scope_Index.new( @formal_operation ).execute
        @_stated_box = sb
        __partition
        self
      end

      # -- evaluation

      def evaluation_proc__

        -> par do
          send EVAL___.fetch( @_set_via_name_symbol.fetch( par.name_symbol ) ), par
        end
      end

      EVAL___ = {
        _appropriated_: :__evaluate_appropriated_parameter,
        _bespoke_: :__evaluate_bespoke_parameter,
      }

      def __evaluate_bespoke_parameter par
        @procure_bound_call_.evaluate_bespoke_parameter__ par
      end

      def __evaluate_appropriated_parameter par

        k = par.name_symbol
        h = @scope_index_.evaluations_cache_
        sta = h[k]
        if sta
          sta.in_progress and self._CYCLIC
        else
          ___establish_state par
          sta = h.fetch k
        end
        sta.cached_evaluation_
      end

      def ___establish_state par

        k = par.name_symbol
        h = @scope_index_.evaluations_cache_

        bs = _create_session_for par

        h[ k ] = bs  # so we can detect cycles
        sta = bs.execute
        h[ k ] = sta
        NIL_
      end

      def begun_session_for_build_state_for__ par
        self._WHEN
        _create_session_for( par ).begin_session__
      end

      def _create_session_for par
        Here_::Build_State___.new par, self
      end

      # -- indexing

      def __partition_as_recurse

        bx = Callback_::Box.new

        _ = @formal_operation.to_defined_formal_parameter_stream.map_by do |par|
          bx.add par.name_symbol, par
          par
        end

        _partition _

        @_stated_box = bx ; nil
      end

      def __partition
        _partition @_stated_box.to_value_stream
        NIL_
      end

      def _partition st

        set_via_name_symbol = {}
        list_of_bespokes = []

        is_in_scope = @scope_index_.yes_no_read_only_hash__

        begin
          par = st.gets
          par or break
          k = par.name_symbol
          if is_in_scope[ k ]
            set_via_name_symbol[ k ] = :_appropriated_
          else
            set_via_name_symbol[ k ] = :_bespoke_
            list_of_bespokes.push par
          end
          redo
        end while nil

        @_bespoke_parameters = list_of_bespokes
        @_set_via_name_symbol = set_via_name_symbol ; nil
      end

      def to_expanse_stream
        self._EG
        @_stated_box.to_value_stream
      end

      def is_appropriated__ k
        :_appropriated_ == @_set_via_name_symbol.fetch( k )
      end

      def to_bespoke_stream__
        Callback_::Stream.via_nonsparse_array @_bespoke_parameters
      end

      attr_reader(
        :procure_bound_call_,
        :scope_index_,
      )
    end
  end
end
# #history: a rewrite and rename of "frame index"
