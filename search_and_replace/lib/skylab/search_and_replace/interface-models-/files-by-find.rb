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
      @_nf = nf
    end

    def name_
      @_nf
    end

    def interpret_component st, & pp

      # this is how you be a button:

      if st.no_unparsed_exists

        dup.___bound_call_as_hot( & pp )
      end
    end

    def ___bound_call_as_hot & oes_p_p

      @_oes_p = oes_p_p[ self ]

      Callback_::Bound_Call[ nil, self, :___execute ]
    end

    def ___execute

      _ok = ___init_command
      _ok &&= __via_command
    end

    def ___init_command

      x = Home_.lib_.system.filesystem.find(

        :filenames, @filename_patterns,
        :paths, @paths,
        :freeform_query_infix_words, %w'-type f',
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
