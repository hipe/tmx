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
    end

    def __files_by_find__component_operation

      Interface_Models_::Files_by_Find
    end

    def __files_by_grep__component_operation

      Interface_Models_::Files_by_Grep
    end

    def __counts__component_operation

      Interface_Models_::Counts
    end

    def __matches__component_operation

      yield :unavailability, @_zerk_index_.unavailability_proc
      yield :parameters_from, @_zerk_index_.reader_proc

      Interface_Models_::Matches
    end

    def __replacement_expression__component_association

      # always from this frame the caller has the ability to specify a
      # replacement expression.

      Any_value_
    end

    def __replace__component_operation

      yield :unavailability, @_zerk_index_.unavailability_proc
      yield :parameters_from, @_zerk_index_.reader_proc

      Home_::Interface_Models_::Replace
    end

    def __functions_directory__component_association

      Any_value_
    end

    Any_value_ = -> st, & _pp do
      if st.unparsed_exists
        Callback_::Known_Known[ st.gets_one ]
      end
    end
  end
end
