module Skylab::SearchAndReplace

  class Interface_Models_::Files_by_Find

    def self.describe_into_under y, expag
      y << "previews all files matched by the `find` query"
    end

    PARAMETERS = Attributes_.call(
      filename_patterns: [ :optional, :plural ],
      paths: :plural,
    )
    attr_writer( * PARAMETERS.symbols )

    def initialize & oes_p
      @filename_patterns = nil
      @_oes_p = oes_p
    end

    def execute

      cmd = Home_.lib_.system.filesystem.find(

        :filenames, @filename_patterns,
        :paths, @paths,
        :freeform_query_infix_words, %w(-type f),
        :when_command, IDENTITY_,
        & @_oes_p )

      if cmd
        cmd.to_path_stream
      else
        cmd
      end
    end

    def handle_event_selectively_for_zerk  # for [#ac-027]
      @_oes_p
    end
  end
end
# #history - this splintered off of node [#003]
# [#bs-028] (method name conventions) references this document
