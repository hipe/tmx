module Skylab::Headless

  module CLI::Action_::Desc__  #  read [#033] the section par..

    class << self

      def parse_sections sec_a, line_a
        Parse_sections__[ sec_a, line_a ]
      end

      def section * a
        Section__.new( * a )
      end

      def story x
        Story__[ x ]
      end
    end

    Section__ = ::Struct.new( :header, :lines ) do
      def any_nonzero_length_line_a
        (( a = lines )).length.nonzero? and a
      end
    end

    class Story__

      class << self
        alias_method :[], :new
      end

      def initialize node
        @client = node
        resolve_desc_lines_and_sections
        @client = nil ; freeze  # freezing isn't necessary, just preferable
      end
      attr_reader :has_nonzero_desc_lines, :has_nonzero_sections
      def desc_lines_count
        @has_nonzero_desc_lines ? @desc_s_a.length : 0
      end
      def fetch_first_desc_line
        @desc_s_a.fetch 0
      end
      def desc_lines
        @desc_s_a
      end
      def sections
        if block_given?
          scn = get_section_stream ; section = nil
          yield section while section = scn.gets
        else
          to_enum :sections
        end
      end
      def get_section_stream
        a = @sect_a ; d = -1 ; last = a.length - 1
        Scn_.new { d < last and a.fetch( d += 1 ) }
      end
    private
      def resolve_desc_lines_and_sections
        @has_nonzero_desc_lines = @has_nonzero_sections = false
        pdcr = get_any_desc_lines_producer
        @writable_sect_a = []
        pdcr and absorb_desc_lines_and_sections_from_raw_lines_producer pdcr
        @client.add_any_supplemental_sections_for_stry @writable_sect_a
        bake_sect_a ; nil
      end
      def get_any_desc_lines_producer
        p_a = @client.any_description_p_a_for_stry
        p_a and build_producer_from_p_a p_a
      end
      def build_producer_from_p_a p_a
        Callback_.stream.via_nonsparse_array( p_a ).expand_by do |p|
          y = []
          @client.instance_exec y, & p
          Callback_.stream.via_nonsparse_array y
        end
      end
      def absorb_desc_lines_and_sections_from_raw_lines_producer producer
        Parse_sections__[ @writable_sect_a, producer ]
        @writable_sect_a.length.zero? or absorb_any_first_section_as_desc_a
        nil
      end
      def absorb_any_first_section_as_desc_a
        @writable_sect_a.first.header or
          absorb_first_section_as_desc_a @writable_sect_a.shift ; nil
      end
      def absorb_first_section_as_desc_a sect
        s_a = sect.lines.reduce [] do |m, x|
          m << x.last
        end
        s_a.length.zero? and self.fail_sanity
        @has_nonzero_desc_lines = true
        @desc_s_a = s_a.freeze ; nil
      end
      def bake_sect_a
        if @writable_sect_a.length.nonzero?
          @has_nonzero_sections = true
          @sect_a = @writable_sect_a.freeze
        end
        @writable_sect_a = nil
      end
    end

    state_h = { }  # das state machine

    state = ::Struct.new :rx, :to

    #         name               regex         which can be followed by..

    state_h[ :initial ] = state[ nil,          [ :section, :desc ] ]
    state_h[ :desc    ] = state[ //,           [ :section, :normal ] ]
    state_h[ :normal  ] = state[ //,           [ :section, :normal ] ]
    state_h[ :section ] = state[ /\A[^:]+:\z/, [ :item, :normal ] ]
    state_h[ :item    ] = state[
                       /\A(?<ind> +)(?<hdr>((?!  ).)+)(?: {2,}(?<bdy>.+))?\z/,
                                      [ :subitem, :item, :section, :normal ] ]
    state_h[ :subitem ] = state[ nil, # (<- guess what will happen here)
                                      [ :subitem, :item, :section, :normal ] ]

    item_rx_h = ::Hash.new { |h, k| h[k] = /\A {#{ k },}(.+)\z/ }  # cache rx

    Parse_sections__ = -> sections, lines do
      stat = state_h[ :initial ]  # (var meaning change!!)
      section = line = nil
      push = -> { sections << ( section = Section__.new nil, [] )  }
      trigger_h = {
        desc:    -> { push[] ; section.lines << [ :line, line ] },
        section: -> { push[] ; section.header = line },
        normal:  -> {          section.lines << [ :line, line ] },
        item:    -> {          section.lines << [ :item, * $~.captures[1..-1]]
                               state_h[:subitem].rx =  # *NOTE* not #idempotent
                                 item_rx_h[ $~[:ind].length + 1 ] },
        subitem: -> {          section.lines << [ :item, nil, $~[1] ] }
      }
      while (( line = lines.gets ))
        line.chomp!
        name_i = stat.to.detect do |i|
          state_h[ i ].rx =~ line
        end
        trigger_h.fetch( name_i ).call
        stat = state_h.fetch name_i
      end ; nil
    end
  end
end
