module Skylab::SearchAndReplace

  class Interface_Models_::Matches

    def description
      'see the matching strings (not just files)'
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

        Callback_::Bound_Call[ nil, dup, :___to_match_stream, & pp ]
      end
    end

    def ___to_match_stream & pp

      @_pp = pp
      @_oes_p = pp[ nil ]

      ok = __resolve_file_path_stream
      ok &&= __resolve_file_session_stream
      ok && ___via_file_session_stream
    end

    def ___via_file_session_stream

      @_file_session_stream.expand_by do | read_only_fsess |

        read_only_fsess.to_read_only_match_stream
      end
    end

    def __resolve_file_session_stream

      o = @_files_by_grep

      _ = Home_::Magnetics_::File_Session_Stream_via_Parameters.with(
        :do_highlight, nil, # NOTE eventually..
        :upstream_path_stream, @_file_path_stream,
        :ruby_regexp, o.ruby_regexp,
        :grep_extended_regexp_string, o.grep_extended_regexp_string,
        :read_only,
        & @_oes_p
      )

      _write_trueish :@_file_session_stream, _
    end

    def __resolve_file_path_stream

      _ = @_files_by_grep.call :for, :paths, & @_pp
      _write_trueish :@_file_path_stream, _
    end

    def _write_trueish ivar, x
      if x
        instance_variable_set ivar, x
        ACHIEVED_
      else
        x
      end
    end
  end
end

# #history: this splintered off of node [#003]
