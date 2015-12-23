module Skylab::SearchAndReplace

  class Interface_Models_::Files_by_Find

    # the #frontier "button" (of new zerk)

    def description
      "previews all files matched by the `find` query"
    end

    def initialize paths, fn_patterns, nf  # assume nonzero paths

      if block_given?
        self._COLD_MODEL_do_not_pass_handler_at_construction
      end

      @filename_patterns = fn_patterns
      @paths = paths
      @name_ = nf
    end

    attr_reader :name_

    # -- this is how you be a button:

    def interpret_component st, & pp

      if st.no_unparsed_exists
        dup._init_hot( & pp ).___to_bound_call
      end
    end

    def ___to_bound_call
      Callback_::Bound_Call[ nil, self, :_execute ]
    end

    # -- this is how we be an internal service (eek?):

    def invoke & pp

      dup._init_hot( & pp )._execute
    end

    # --

    def _init_hot & oes_p_p  # assume freshly duped
      @_oes_p = oes_p_p[ self ]
      self
    end

    def _execute

      _ok = ___init_command
      _ok &&= __via_command
    end

    def ___init_command

      x = Home_.lib_.system.filesystem.find(

        :filenames, @filename_patterns,
        :paths, @paths,
        :freeform_query_infix_words, %w(-type f),
        :when_command, IDENTITY_,
        & @_oes_p )

      if x
        @_command = x ; ACHIEVED_
      else
        x
      end
    end

    def __via_command
      @_command.to_path_stream
    end
  end
end
# #history - this splintered off of node [#003]
# [#bs-028] (method name conventions) references this document
