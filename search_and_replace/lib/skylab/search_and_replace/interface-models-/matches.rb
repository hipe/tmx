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

    def initialize & p
      @egrep_pattern = nil
      @_listener = p
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
      __store_trueish :@_file_session_stream, _
    end

    def __build_read_only_file_session_stream
      o = _begin_common_file_session_stream
      o.for = :read_only
      o.execute
    end

    def to_string_edit_session_stream_for__ repl_params_x  # highlight eventually
      o = _begin_common_file_session_stream
      o.for = :for_interactive_search_and_replace
      o.replacement_parameters = repl_params_x
      o.execute
    end

    def _begin_common_file_session_stream
      o = Home_::Magnetics_::FileSession_Stream_via_Parameters.new( & @_listener )
      o.ruby_regexp = @ruby_regexp
      o.upstream_path_stream = @files_by_grep
      o.grep_extended_regexp_string = @egrep_pattern
      o
    end

    def handle_event_selectively_for_zerk
      @_listener
    end

    define_method :__store_trueish, METHOD_DEFINITION_FOR_STORE_TRUEISH_
  end
end
# #history: this splintered off of node [#003]
