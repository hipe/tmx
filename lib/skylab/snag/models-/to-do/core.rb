module Skylab::Snag

  class Models_::To_Do  # see [#003]

    # :desc, 'actions that work with TODO-like tags'

    class << self

      def default_pattern_strings
        DEFAULT_PATTERN_STRINGS___
      end
    end  # >>

    DEFAULT_PATTERN_STRINGS___ = [ '#todo\>'.freeze ]

    def initialize
      @ending_of_message = nil
      yield self
      freeze
    end

    def accept_matching_line line_o
      @_matching_line = line_o
      NIL_
    end

    def accept_header_range begin_, end_
      @header_r = begin_ ... end_
      NIL_
    end

    def accept_body_range begin_, end_
      @body_r = begin_ ... end_
      NIL_
    end

    def accept_ending_of_message d
      @ending_of_message = d
      NIL_
    end

    def express_into_under y, expag

      o = @_matching_line
      y << "#{ o.path }:#{ o.line_number }:#{ o.full_source_line }"
      ACHIEVED_
    end

    # ~ begin

    def any_pre_tag_string

      if @header_r.begin.nonzero?

        full_source_line[ 0 ... @header_r.begin ]
      end
    end

    def tag_string

      full_source_line[ @body_r ]
    end

    def any_post_tag_string  # almost always exists b.c newline

      s = full_source_line
      d = @body_r.end
      d_ = @ending_of_message
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

    def line_number
      @_matching_line.line_number
    end

    def path
      @_matching_line.path
    end

    def beginning_of_header
      @header_r.begin
    end


    module Expression_Adapters
      EN = nil
    end


    Autoloader_[ Actions = ::Module.new, :boxxy ]
    Autoloader_[ Actors_ = ::Module.new ]
    Brazen_ = Snag_.lib_.brazen
    PIPE_ = '|'.freeze
    To_Do_ = self

  end
end
