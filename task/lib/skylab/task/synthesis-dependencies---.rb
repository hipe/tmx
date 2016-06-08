class Skylab::Task

  class Synthesis_Dependencies___  # read [#008]

    class << self

      def _ task, args_a, index
        new( task, args_a, index ).execute
      end

      alias_method :call, :_
      alias_method :[], :_
      remove_method :_

      private :new
    end  # >>

    def initialize task, args_a, index
      @_args_a = args_a
      @_index = index
      @_task = task
    end

    def execute

      _ok = ___execute_chain
      _ok && @_task.execute
    end

    def ___execute_chain

      ok = true
      st = Common_::Stream.via_times @_args_a.length
      begin
        d = st.gets
        d or break
        args = @_args_a.fetch d
        _dep = Dependency___.new args
        ok = Call_Dependency___.new( _dep, @_task, @_index ).execute
        ok or break
        redo
      end while nil
      ok
    end

    class Call_Dependency___

      # a synthesis call is a fresh context free of previous indexing..

      # share all relevant parameters from the front node to the remote
      # node. relevancy is the set intersect (taking into account name-
      # mappings). whine on bad references.

      def initialize dep, t, idx
        @_dep = dep
        @_index = idx
        @_task = t
      end

      def execute
        __share_parameters
        _ok = @_rtask.execute_as_front_task
        _ok && ___store_result_task
      end

      def ___store_result_task

        # (we could go higher up on the chain of methods that deliver one
        # task to another, e.g there is also `receive_dependency_completion`)

        nf = @_dep.task_name_for_local_storage
        if ! nf
          _ = @_rtask.name_symbol_for_storage_
          nf = Common_::Name.via_variegated_symbol _
        end

        @_task.receive_dependency_completion_value_and_name_ @_rtask, nf

        ACHIEVED_
      end

      def __share_parameters

        @_rtask = Dereference_.new( @_dep.task_name_symbol, @_index ).to_task_

        bx = @_dep.parameter_name_mappings
        if bx
          alt_name_pool_h = bx.h_.dup
          @_alt_name_pool = alt_name_pool_h.method :delete
        else
          @_alt_name_pool = MONADIC_EMPTINESS_
        end

        foz = @_rtask.formal_parameters__
        if foz
          ___write_parameters_at_set_intersect foz
        end

        if alt_name_pool_h && alt_name_pool_h.length.nonzero?
          self._COVER_ME_UNUSED_REFERENCES_IN_NAME_MAPPINGS
        end
        NIL_
      end

      def ___write_parameters_at_set_intersect foz

        # for those formal parameters in the set defined by the remote task,
        # for each one apply any name mapping to get the local parameter
        # name. IFF that parameter is known locally, write it to the new
        # parameters box for the remote call. confirm etc.

        rs = Home_.lib_.fields::Ivar_based_Store.new @_task  # read store

        _attrs = foz.as_attributes_
        st = _attrs.to_defined_attribute_stream
        begin
          remote_atr = st.gets
          remote_atr or break
          k = remote_atr.name_symbol
          alt_k = @_alt_name_pool[ k ]
          local_atr = if alt_k
            Common_::Name.via_variegated_symbol alt_k
          else
            remote_atr
          end
          if rs.knows local_atr
            _x = rs.retrieve local_atr
            @_rtask.add_parameter k, _x
          end
          redo
        end while nil
        NIL_
      end
    end

    class Dependency___  # just parse

      def initialize args
        @_st = Common_::Polymorphic_Stream.via_array args
        @task_name_symbol = @_st.gets_one
        until @_st.no_unparsed_exists
          send SYNTAX___.fetch @_st.gets_one
        end
        remove_instance_variable :@_st
      end

      SYNTAX___ = {
        as: :__process_alias_of_task,
        parameter: :__process_parameter_statement,
      }

      def __process_alias_of_task
        _ = Common_::Name.via_variegated_symbol @_st.gets_one
        @task_name_for_local_storage = _
        NIL_
      end

      def __process_parameter_statement
        @_current_parameter_name = @_st.gets_one
        send PARAMETER_SYNTAX___.fetch @_st.gets_one
      end

      PARAMETER_SYNTAX___ = {
        via_parameter: :__add_parameter_name_mapping,
      }

      def __add_parameter_name_mapping

        _remote_name_sym = remove_instance_variable :@_current_parameter_name
        _local_name_symbol = @_st.gets_one

        ( @parameter_name_mappings ||= Common_::Box.new ).add(
          _remote_name_sym, _local_name_symbol )

        NIL_
      end

      attr_reader(
        :parameter_name_mappings,
        :task_name_for_local_storage,
        :task_name_symbol,
      )
    end

    MONADIC_EMPTINESS_ = -> _ { NOTHING_ }
  end
end
