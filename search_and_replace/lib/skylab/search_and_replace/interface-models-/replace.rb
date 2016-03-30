module Skylab::SearchAndReplace

  class Interface_Models_::Replace

    # the "replace" operation (from the perspective of what the API must do)
    # is not so different from the "matches" operation - ..

    PARAMETERS = Attributes_.call(
      matches: nil,
      replacement_expression: :_read,
      functions_directory: [ :optional, :_read ],
    )

    attr_writer( * PARAMETERS.symbols )

    attr_reader( * PARAMETERS.symbols( :_read ) )

    def initialize & oes_p
      @functions_directory = nil
      @_oes_p = oes_p
    end

    def finish__matches__by o

      # with this what we're saying is "don't call `execute` (or anything
      # else) on the matches session (if you get as far as resolving it).
      # we just let it pass thru so that for `@matches` what we have is the
      # not-yet-executed session, rather than its result. (our main
      # dependency will do something special with it.)

      o.respond_to? :to_mutable_file_session_stream_for__ or self._HI
      o
    end

    def execute
      @matches.to_mutable_file_session_stream_for__ self
    end

    def handle_event_selectively_for_zerk
      @_oes_p
    end
  end
end
# #history: this used to hold almost half the content of all interface nodes
