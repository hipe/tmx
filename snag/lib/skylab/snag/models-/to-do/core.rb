module Skylab::Snag

  class Models_::ToDo  # see [#003]

    # :desc, 'actions that work with TODO-like tags'

    class << self

      def default_pattern_strings
        DEFAULT_PATTERN_STRINGS___
      end
    end  # >>

    DEFAULT_PATTERN_STRINGS___ = [ '#todo\>'.freeze ]

    def initialize
      @_index_of_ending_of_message = nil
      yield self
      @_late = {}
      freeze
    end

    def accept_matching_line line_o
      @_matching_line = line_o
      NIL_
    end

    def accept_header_range begin_, end_
      @_header_r = begin_ ... end_
      NIL_
    end

    def body_range
      @_body_r
    end

    def accept_body_range begin_, end_
      @_body_r = begin_ ... end_
      NIL_
    end

    def accept_ending_of_message d
      @_index_of_ending_of_message = d
      NIL_
    end

    def express_into_under y, expag

      o = @_matching_line
      y << "#{ o.path }:#{ o.lineno }:#{ o.full_source_line }"
    end

    # ~ begin

    def any_pre_tag_string

      if @_header_r.begin.nonzero?

        full_source_line[ 0 ... @_header_r.begin ]
      end
    end

    def tag_string

      full_source_line[ @_body_r ]
    end

    def chomped_post_tag_string

      @_late[ :chomped_post_tag_string ] ||= __frozen_chomped_post_tag_string
    end

    def __frozen_chomped_post_tag_string

      s = any_post_tag_string
      if s
        s.chomp!
        s.freeze
      else
        EMPTY_S_
      end
    end

    def any_post_tag_string  # almost always exists b.c newline

      s = full_source_line
      d = @_body_r.end
      d_ = @_index_of_ending_of_message
      if d_
        self._FUN  # #todo cover this
      else
        d_ = s.length
      end
      s[ d ... d_ ]
    end

    # ~ end

    def full_source_line
      @_matching_line.full_source_line
    end

    def lineno
      @_matching_line.lineno
    end

    def path
      @_matching_line.path
    end

    def beginning_of_header
      @_header_r.begin
    end

    module ExpressionAdapters
      EN = nil
    end

    Autoloader_[ self ]

    stowaway :Modalities, 'modalities/cli/actions/to-stream'

    Brazen_ = Home_.lib_.brazen
    PIPE_ = '|'.freeze
    Here_ = self
  end
end
