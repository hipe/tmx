module Skylab::SearchAndReplace

  class Interface_Models_::Matches

    def self.describe_into_under y, _expag
      y << 'see the matching strings (not just files)'
    end

    PARAMETERS = Attributes_.call(
      files_by_grep: nil,
      ruby_regexp: nil,
      egrep_pattern: :optional,
    )
    attr_writer( * PARAMETERS.symbols )

    def initialize & oes_p
      @egrep_pattern = nil
      @_oes_p = oes_p
    end

    def finish__files_by_grep__by o  # see sib
      o.for = :paths
      o.execute
    end

    def execute  # formerly "to match stream"

      _ok = __resolve_file_session_stream
      _ok && ___via_file_session_stream
    end

    def ___via_file_session_stream

      @_file_session_stream.expand_by do | read_only_fsess |

        read_only_fsess.to_read_only_match_stream
      end
    end

    def __resolve_file_session_stream

      _ = __build_read_only_file_session_stream

      __write_trueish :@_file_session_stream, _
    end

    def __build_read_only_file_session_stream

      o = _begin_common_file_session_stream
      o.for = :read_only
      o.execute
    end

    def to_mutable_file_session_stream_for__ repl_params_x  # highlight eventually

      o = _begin_common_file_session_stream
      o.for = :for_interactive_search_and_replace
      o.replacement_parameters = repl_params_x
      o.execute
    end

    def _begin_common_file_session_stream

      o = Home_::Magnetics_::File_Session_Stream_via_Parameters.new( & @_oes_p )
      o.ruby_regexp = @ruby_regexp
      o.upstream_path_stream = @files_by_grep
      o.grep_extended_regexp_string = @egrep_pattern
      o
    end

    def __write_trueish ivar, x
      if x
        instance_variable_set ivar, x
        ACHIEVED_
      else
        x
      end
    end

    def handle_event_selectively_for_zerk
      @_oes_p
    end
  end
end
# #history: this splintered off of node [#003]
