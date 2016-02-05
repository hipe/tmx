module Skylab::SearchAndReplace

  class Interface_Models_::Files_by_Grep

    def description
      'list the matching filenames (but not the strings)'
    end

    PARAMETERS = Parameters_[
      egrep_pattern: :optional,
      files_by_find: nil,
      ruby_regexp: nil,
    ]
    attr_writer( * PARAMETERS.symbols )

    def initialize & oes_p

      @do_highlight = nil
      @egrep_pattern = nil
      @for = :paths
      @_oes_p = oes_p
    end

    def to_file_path_stream * x_a, & pp
      self._INTERESTING
      call = dup._init_as_hot( & pp )
      Parameters_[ for: nil ].init call, x_a
      call._to_path_stream
    end

    def execute
      o = Home_::Magnetics_::Grep_Path_Stream_via_Parameters.new( & @_oes_p )
      o.grep_extended_regexp_string = @egrep_pattern
      o.for = @for
      o.ruby_regexp = @ruby_regexp
      o.upstream_path_stream = @files_by_find
      o.execute
    end

    def handle_event_selectively_for_ACS  # because [#ac-027]
      @_oes_p
    end
  end
end
# #history: this splintered off of node [#003]
