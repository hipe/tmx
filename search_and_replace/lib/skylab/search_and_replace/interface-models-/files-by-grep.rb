module Skylab::SearchAndReplace

  class Interface_Models_::Files_by_Grep

    def self.describe_into_under y, _expag
      y << 'list the matching filenames (but not the strings)'
    end

    PARAMETERS = Attributes_.call(
      egrep_pattern: :optional,
      files_by_find: nil,
      ruby_regexp: nil,
    )
    attr_writer( * PARAMETERS.symbols )

    attr_writer(  # [#ac-027]#A - system-private API
      :for,
    )

    def initialize & p

      @do_highlight = nil
      @egrep_pattern = nil
      @for = :paths
      @_listener = p
    end

    def to_file_path_stream * x_a, & pp
      self._INTERESTING
      call = dup._init_as_hot( & pp )
      Attributes_[ for: nil ].init call, x_a
      call._to_path_stream
    end

    def execute
      o = Home_::Magnetics_::Grep_Path_Stream_via_Parameters.new( & @_listener )
      o.grep_extended_regexp_string = @egrep_pattern
      o.for = @for
      o.ruby_regexp = @ruby_regexp
      o.upstream_path_stream = @files_by_find
      _x = o.execute
      _x || NOTHING_  # #false-means-false-in-zerk
    end

    def handle_event_selectively_for_zerk  # because [#ac-027]
      @_listener
    end
  end
end
# #history: this splintered off of node [#003]
