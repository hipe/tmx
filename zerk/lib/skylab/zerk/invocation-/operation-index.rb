module Skylab::Zerk

  module Invocation_

    class Operation_Index  # 1x. notes in [#013]

      # (we don't know yet how public this will need to be..)

      class << self

        def for_top_ sb, fo
          _begin_empty.__index_for_top sb, fo
        end

        alias_method :_begin_empty, :new
        undef_method :new
      end  # >>

      def dup_for_recursion_ fo
        self.class._begin_empty.___init_as_recurse fo, self
      end

      def ___init_as_recurse fo, otr

        @formal_operation = fo
        @scope_index_ = otr.scope_index_
        __partition_as_recurse
        self
      end

      def __index_for_top sb, fo

        @formal_operation = fo
        @scope_index_ = Here_::Scope_Index.new( @formal_operation ).execute
        @_stated_box = sb
        _partition @_stated_box.to_value_stream
        self
      end

      # -- evaluation

      def evaluation_proc_for_ pbc
        Here_::Evaluation.proc_for_ pbc, self
      end

      # -- indexing

      def __partition_as_recurse

        bx = Common_::Box.new

        _ = @formal_operation.to_defined_formal_parameter_stream.map_by do |par|
          bx.add par.name_symbol, par
          par
        end

        _partition _

        @_stated_box = bx ; nil
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
        @_set_symbol_via_name_symbol = set_via_name_symbol ; nil
      end

      def to_expanse_stream
        self._EG
        @_stated_box.to_value_stream
      end

      def is_appropriated_ k
        :_appropriated_ == @_set_symbol_via_name_symbol.fetch( k )
      end

      def to_PVS_parameter_stream_
        Stream_[ @_bespoke_parameters ]
      end

      def fetcher_proc_for_reception_set_symbol_via_name_symbol_
        @_set_symbol_via_name_symbol.method :fetch
      end

      attr_reader(
        :scope_index_,
      )
    end
  end
end
# #history: a rewrite and rename of "frame index"
