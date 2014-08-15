module Skylab::Snag

  class Models::Node::Flyweight__

    class << self
      def field_names
        FIELD_NAMES__
      end
    end

    FIELD_NAMES__ = [
      :identifier_prefix,
      :identifier_body,
      :first_line_body,
      :date_string,
      :extra_lines_count
    ].freeze

    def initialize
      @extra_line_a = []
      @first_line = nil
      @indexes = Indexes__.new
      @parse_failure = @is_valid = nil
    end

    attr_reader :extra_line_a, :indexes

    attr_accessor :first_line, :is_valid

    def clear
      @extra_line_a.clear
      @first_line = nil
      @indexes.clear
      @is_valid = nil
    end

    def yaml_data_pairs  # alla `field_names`
      a = [
        [ :identifier_body, identifier_body ],
        [ :first_line_body, first_line_body ] ]
      if (( s = date_string ))
        a.push [ :date_string, s ]
      end
      if extra_lines_count.nonzero?
        a.push [ :extra_lines_count, extra_lines_count ]
      end
      a
    end

    def render_identifier
      @first_line[ @indexes.rendered_identifier_range ]
    end

    def produce_identifier
      Models::Identifier.new identifier_prefix, integer_string, identifier_suffix
    end

    def identifier_prefix
      if @indexes.identifier_prefix.exist?
        @first_line[ @indexes.identifier_prefix.range ]
      end
    end

    def integer
      integer_string.to_i
    end

    def integer_string
      @first_line[ @indexes.integer.range ]
    end

    def identifier_body
      @first_line[ @indexes.identifier_body.range ]
    end

    def identifier_suffix
      if @indexes.integer.end != @indexes.identifier_body.end
        @first_line[ @indexes.integer.end + 1 .. @indexes.identifier_body.end ]
      end
    end

    def first_line_body
      @first_line[ @indexes.body.range ]
    end

    date_rx = /\b\d{4}-\d{2}-\d{2}\b/          # (just know that dates like
                                               # this might be deprecated
    define_method :date_string do              # in lieu of vcs integration)
      if date_rx =~ @first_line
        $~[0]
      end
    end

    def extra_lines_count
      @extra_line_a.length
    end

    def invalid_reason_event
      parse_failure_event
    end

    def parse_failure_event
      ! @is_valid and @parse_failure
    end

    def set_parse_failure expecting, near, line, line_number, pathname
      # (be sure to set all properties! it is yet another flyweight)
      pf = ( @parse_failure ||= Models::Parse::Events::Failure.new )
      pf.expecting = expecting
      pf.near = near
      pf.line = line
      pf.line_number = line_number
      pf.pathname = pathname
      nil
    end

    class Indexes__

      def initialize
        @body = Index__.new
        @identifier_body = Index__.new
        @identifier_prefix = Index__.new
        @integer = Index__.new
      end

      attr_reader :body, :identifier_body, :identifier_prefix, :integer

      def clear
        @body.clear
        @identifier_prefix.clear
        @identifier_body.clear
        @integer.clear
      end

      define_method :rendered_identifier_range, -> do
        headcap_d = endcap_d = nil
        constants = -> do
          headcap_d = Models::Identifier::CONTENT_START_INDEX
          endcap_d = Models::Identifier::ENDCAP_WIDTH
          constants = nil
        end
        -> do
          constants && constants[]
          ( @identifier_prefix.begin || @integer.begin ) - headcap_d ..
            @identifier_body.end + endcap_d
        end
      end.call

      class Index__
        def initialize
          @begin = @end = nil
        end
        alias_method :clear, :initialize ; public :clear
        attr_accessor :begin, :end
        def exist?
          ! @begin.nil?
        end
        def range
          @begin .. @end
        end
      end
    end
  end
end
