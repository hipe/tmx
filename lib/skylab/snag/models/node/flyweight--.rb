module Skylab::Snag

  class Models::Node::Flyweight__

    field_names = [
      :identifier_prefix,
      :identifier_body,
      :first_line_body,
      :date_string,
      :extra_lines_count
    ]

    define_singleton_method :field_names do field_names end

    def initialize manifest_pathname
      @extra_line_a = []
      @first_line = nil
      @indexes = Indexes__.new
      @manifiset_pathname = manifest_pathname
      @parse_failure = @valid = nil
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

    def build_identifier
      Models::Identifier.new identifier_prefix, identifier_body, integer_string
    end

    define_method :each_node do |line_producer, node_consumer|
      o = @indexes
      line = nil
      scn = Snag_::Library_::StringScanner.new EMPTY_S_
      gets = -> do
        line = line_producer.gets and scn.string = line
      end
      failure = -> exp do
        parse_failure! exp, scn.peek( 8 ), line,
          line_producer.line_number, line_producer.pathname
        node_consumer << self
        gets[ ]
      end
      gets[ ]
      while line
        clear
        '[#' == scn.peek( 2 ) or next failure[ '[#' ]
        @first_line = line
        pos = (scn.pos += 2)
        if scn.skip( /[a-z]+-/ )                            # identifier_prefix?
          o.identifier_prefix.begin, o.identifier_prefix.end =
            pos, (pos = scn.pos) - 2
        end
        scn.skip( /\d+/ ) or next failure[ 'digits' ]
        o.integer.begin = o.identifier_body.begin = pos      # integer &
        o.integer.end = scn.pos - 1                          #  identifier_body
        scn.skip( /(\.\d+)+/ )
        o.identifier_body.end = scn.pos - 1
        scn.skip( /\][\t ]*/ ) or next failure[ ']' ]
        o.body.begin, o.body.end = scn.pos, line.length - 1  # body
        if gets[ ]
          if scn.match?( /[ \t]/ )                           # extra lines
            loop do
              @extra_line_a.push line
              gets[ ] or break
              scn.match?( /[ \t]+/ ) or break
            end
          end
        end
        @valid = true
        node_consumer << self
      end
    end

    date_rx = /\b\d{4}-\d{2}-\d{2}\b/          # (just know that dates like
                                               # this might be deprecated
    define_method :date_string do              # in lieu of vcs integration)
      if date_rx =~ @first_line
        $~[0]
      end
    end

    attr_reader :extra_line_a

    def extra_lines_count
      @extra_line_a.length
    end

    attr_reader :first_line                    # used in some reports, comp next

    def first_line_body
      @first_line[ @indexes.body.range ]
    end

    def integer_string
      @first_line[ @indexes.integer.range ]
    end

    def integer
      integer_string.to_i
    end

    def identifier_body
      @first_line[ @indexes.identifier_body.range ]
    end

    def invalid_reason
      parse_failure # for now
    end

    def identifier_prefix
      if @indexes.identifier_prefix.exist?
        @first_line[ @indexes.identifier_prefix.range ]
      end
    end

    def rendered_identifier
      Models::Identifier.render identifier_prefix, identifier_body
    end

    attr_reader :valid
    alias_method :valid?, :valid

    def yaml_data_pairs # make sure you use `field_names` !
      a = [
        [:identifier_body, identifier_body],
        [:first_line_body, first_line_body]
      ]
      if (ds = date_string)
        a.push [:date_string, ds]
      end
      if extra_lines_count > 0
        a.push [:extra_lines_count, extra_lines_count]
      end
      a
    end

  private

    def clear
      @extra_line_a.clear
      @first_line = nil
      @indexes.clear
      @valid = nil
    end

    def parse_failure
      ! @valid and @parse_failure
    end

    def parse_failure! expecting, near, line, line_number, pathname
      # (be sure to set all properties! it is yet another flyweight)
      pf = ( @parse_failure ||= Models::Parse::Events::Failure.new )
      pf.expecting = expecting
      pf.near = near
      pf.line = line
      pf.line_number = line_number
      pf.pathname = pathname
      nil
    end
  end
end
