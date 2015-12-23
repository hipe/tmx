module Skylab::SearchAndReplace

  class Interface_Models_::Counts

    def description
      "the grep --count option - \"Only a count of selected lines ..\""
    end

    def initialize fbg, nf

      @_files_by_grep = fbg
      @name_ = nf
    end

    attr_reader(
      :name_,
    )

    def interpret_component st, & pp

      if st.no_unparsed_exists

        Callback_::Bound_Call[ nil, dup, :___to_count_stream, & pp ]
      end
    end

    def ___to_count_stream & pp

      @_files_by_grep.call(
        :for, :counts,
        & pp )
    end
  end
end
