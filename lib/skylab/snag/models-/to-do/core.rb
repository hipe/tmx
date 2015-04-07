module Skylab::Snag

  class Models_::To_Do  # see [#003]

    # :desc, 'actions that work with TODO-like tags'

    class << self

      def default_pattern_strings
        DEFAULT_PATTERN_STRINGS___
      end
    end  # >>

    DEFAULT_PATTERN_STRINGS___ = [ '[@#]todo\>'.freeze ]

    def initialize
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

    def beginning_of_header
      @header_r.begin
    end

    def line_number
      @_matching_line.line_number
    end

    def path
      @_matching_line.path
    end

    Autoloader_[ Actions = ::Module.new, :boxxy ]
    Autoloader_[ Actors_ = ::Module.new ]
    Brazen_ = Snag_.lib_.brazen
    PIPE_ = '|'.freeze
    To_Do_ = self

  end
end
