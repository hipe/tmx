module Skylab::SearchAndReplace

  class Interface_Models_::Search

    class << self

      def interpret_compound_component p, acs
        p[ new acs ]
      end
      private :new
    end  # >>

    def initialize acs  # assume ruby regexp

      @functions_directory = nil
      @replacement_expression = nil

      _ = acs.instance_variable_get :@_zerk_index_  # ..
      @_zerk_index_ = Zerk_::Index.new self, _
    end

    def __files_by_find__component_operation

      # (assuming that to get to this host node, nonzero paths)

      yield :parameters_from, @_zerk_index_.parent_frame.reader_proc

      Interface_Models_::Files_by_Find
    end

    def __files_by_grep__component_operation

      yield :unavailability, @_zerk_index_.unavailability_proc
      yield :parameters_from, @_zerk_index_.reader_proc

      Interface_Models_::Files_by_Grep
    end

    def __counts__component_operation

      yield :unavailability, @_zerk_index_.unavailability_proc
      yield :parameters_from, @_zerk_index_.reader_proc

      Interface_Models_::Counts
    end

    if false

    def __matches__component_operation

      yield :unavailability, @_common_unav

      Interface_Models_::Matches
    end

    def __replacement_expression__component_association

      # always from this frame the caller has the ability to specify a
      # replacement expression.

      Any_value_
    end

    def __replace__component_operation

      self._REDO  # was Replace_Model_Proxy___
    end

    def __functions_directory__component_association

      Any_value_
    end

    end

    def __WAS_build_replacement_bound_call & pp

      # OK we're still figuring this out - because we form the counterpart
      # association's component model to look "entitesque", we want to
      # result in a bound call here? ..

      dependency = @_component_a.fetch( -1 )
        # yikes - randomly access a volatile UI structure to get a dependency

      if ! dependency.respond_to? :to_mutable_file_session_stream
        self._HARDCODED_OFFSET_CHANGED
      end

      o = Home_::Interface_Models_::Replace.new( & pp )
      o.functions_directory = @functions_directory
      o.streamer = dependency
      o.replacement_expression = @replacement_expression

      _bc = Callback_::Bound_Call[ nil, o, :to_file_session_stream ]

      _bc
    end

    Any_value_ = -> st, & _pp do
      if st.unparsed_exists
        Callback_::Known_Known[ st.gets_one ]
      end
    end
  end
end
