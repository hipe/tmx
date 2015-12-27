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

        _otr = dup._init_as_hot( & pp )

        Callback_::Bound_Call[ nil, _otr, :___to_match_stream ]
      end
    end

    def to_mutable_file_session_stream params_x, & pp  # NOTE highlight eventually

      dup._init_as_hot( & pp ).__to_mutable_file_session_stream params_x
    end

    # == all hot below

    def _init_as_hot & pp
      @_pp = pp
      @_oes_p = @_pp[ self ]
      self
    end

    def __to_mutable_file_session_stream repl_params_x

      ok = _resolve_file_path_stream
      ok && __build_mutable_file_session_stream( repl_params_x )
    end

    def ___to_match_stream

      ok = _resolve_file_path_stream
      ok &&= __resolve_file_session_stream
      ok && ___via_file_session_stream
    end

    def ___via_file_session_stream

      @_file_session_stream.expand_by do | read_only_fsess |

        read_only_fsess.to_read_only_match_stream
      end
    end

    def __resolve_file_session_stream

      _ = __build_read_only_file_session_stream

      _write_trueish :@_file_session_stream, _
    end

    def __build_read_only_file_session_stream

      o = _begin_common_file_session_stream
      o.for = :read_only
      o.execute
    end

    def __build_mutable_file_session_stream repl_params_x

      o = _begin_common_file_session_stream
      o.for = :for_interactive_search_and_replace
      o.replacement_parameters = repl_params_x
      o.execute
    end

    def _begin_common_file_session_stream

      dep = @_files_by_grep

      o = Home_::Magnetics_::File_Session_Stream_via_Parameters.new( & @_oes_p )
      o.ruby_regexp = dep.ruby_regexp
      o.upstream_path_stream = @_file_path_stream
      o.grep_extended_regexp_string = dep.grep_extended_regexp_string
      o
    end

    def _resolve_file_path_stream

      _ = @_files_by_grep.to_file_path_stream :for, :paths, & @_pp
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
