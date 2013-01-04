module Skylab::Snag
  class Models::Node::Flyweight

    field_names = [
      :identifier,
      :first_line_body,
      :date_string,
      :extra_lines_count
    ]

    define_singleton_method :field_names do field_names end


    class Indexes_
      attr_reader :prefix, :integer, :identifier, :body
      def clear
        @prefix.clear
        @integer.clear
        @identifier.clear
        @body.clear
      end
    protected
      def initialize
        @prefix = Index_.new
        @integer = Index_.new
        @identifier = Index_.new
        @body = Index_.new
      end
    end

    class Index_
      attr_accessor :begin, :end
      def clear
        @begin = @end = nil
      end
      def exist?
        ! @begin.nil?
      end
      def range
        @begin .. @end
      end
    protected
      alias_method :initialize, :clear
    end

    define_method :each_node do |line_producer, node_consumer|
      o = @indexes
      line = nil
      scn = Snag::Services::StringScanner.new ''
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
        if scn.skip( /[a-z]+-/ )                             # prefix?
          o.prefix.begin, o.prefix.end = pos, (pos = scn.pos) - 1
        end
        scn.skip( /\d+/ ) or next failure[ 'digits' ]
        o.integer.begin = o.identifier.begin = pos           # integer &
        o.integer.end = scn.pos - 1                          #  identifier
        scn.skip( /(\.\d+)+/ )
        o.identifier.end = scn.pos - 1
        scn.skip( /\][\t ]*/ ) or next failure[ ']' ]
        o.body.begin, o.body.end = scn.pos, line.length - 1  # body
        if gets[ ]
          if scn.match?( /[ \t]/ )                           # extra lines
            loop do
              @extra_lines.push line
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
    define_method :date_string do              # in liew of vcs integration)
      if date_rx =~ @first_line
        $~[0]
      end
    end

    attr_reader :extra_lines

    def extra_lines_count
      @extra_lines.length
    end

    attr_reader :first_line                    # used in some reports, comp next

    def first_line_body
      @first_line[ @indexes.body.range ]
    end

    def integer
      @first_line[ @indexes.integer.range ].to_i
    end

    def identifier_string                      # (not to be confused with the
      @first_line[ @indexes.identifier.range ] # struct (models)!)
    end

    def invalid_reason
      parse_failure # for now
    end

    attr_reader :valid
    alias_method :valid?, :valid

    def yaml_data_pairs # make sure you use `field_names` !
      a = [
        [:identifier, identifier_string],
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

  protected

    def initialize request_client, manifest_pathname
      # experimentally ignore request client for now!

      @valid = nil
      @first_line = nil
      @extra_lines = []
      @indexes = Indexes_.new
      @manifiset_pathname = manifest_pathname
      @parse_failure = nil
    end

    def clear
      @valid = nil
      @first_line = nil
      @extra_lines.clear
      @indexes.clear
    end

    def parse_failure                          # it is a lazily-created fly-
      @parse_failure if ! @valid               # weight so we have to protect
    end                                        # against inappropriate access

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
