module Skylab::Git

  class CLI::Actions::Spread

    Basic = Face::Services::Basic

    def initialize i, o, e
      @y = ::Enumerator::Yielder.new( & e.method( :puts ) )
      @o = o
      @program_name = @is_finished = nil
    end

    attr_writer :program_name

    def invoke argv
      begin
        parse_args argv or break
        normalize or break
        work
      end while nil
      nil
    end

  private

    def invite
      @y << "see '#{ program_name } -h' for help"
      nil
    end

    def program_name
      @program_name || Face::FUN.program_basename[]
    end

    def build_option_parser
      @is_dry_run = false ; @from_file = nil
      @op = Face::Services::OptionParser.new do |op|
        op.on '-n', '--dry-run', 'dry run.' do
          @is_dry_run = true
        end
        op.on '-F', '--file <file>',
          'get list of branch names from <file>' do |file|
            @from_file = file
        end
        op.on '-h', '--help', 'help' do
          help
        end
      end
    end

    def help
      @y << "#{ hi 'usage:' } #{ program_name } [opts] #{ NUM_NUM_ }"
      @y << "#{ hi 'description:' } if you have git branches numbered like"
      @y << "  01-foo-bar, 02-fiz-baz, 03-frank-banger, etc - and you say"
      @y << " `spread 3 7` then 03 becomes 07, 01 becomes 02, and 02 becomes"
      @y << " 04. it's obvious what's happening here."
      @y << "#{ hi 'options:' }"
      @op.summarize @y
      @is_finished = true
    end

    NUM_NUM_ = '<num> <num>'

    Hi_ = -> msg do
      ( @hi ||= Face::FUN.stylize.curry[ [ :green ] ] )[ msg ]
    end

    define_method :hi, & Hi_

    def whine msg
      @y << msg
      false
    end

    def bork msg
      whine msg
      invite
      nil
    end

    def parse_args argv
      -> do  # #result-block
        begin
          build_option_parser.permute! argv
        rescue ::OptionParser::ParseError => e  # i tried to avoid this
          bork e.message
          break
        end
        @is_finished and break nil
        a = [ ]
        while argv.length.nonzero? && (( NUM_RX_ =~ argv[ 0 ] ))
          a << argv.shift.to_i
        end
        argv.length.zero? and break normalize_numbers( a )
        bork "unexpected argument(s) #{ argv.inspect }"
      end.call
    end

    NUM_RX_ = /\A\d+\z/

    def normalize_numbers a
      -> do
        a.length.zero? and break bork( "expecting #{ NUM_NUM_ }" )
        2 == (( len = a.length )) or break bork( "for now, need 2, had #{
          }#{ len } numbers" )
        @move_a =
          a.each_slice( 2 ).map { |from, to| Move_[ from.to_i, to.to_i ] }
        true
      end.call
    end

    def normalize
      if @from_file
        normalize_from_file
      else
        normalize_from_git
      end
    end

    def normalize_from_file
      fh = ::File.open( @from_file, 'r' )
      normalize_from_stream fh
    end

    def normalize_from_git
      _i, o, _e = Face::Services::Open3.popen3 "git branch | cut -c 3-"
      _e.close ; _i.close
      normalize_from_stream o
    end

    def normalize_from_stream io
      @scn = Basic::List::Scanner[ io ]
    end

    def work
      begin
        normalize_some_lines or break
        p = Preparer_.new( @y, @item_a, @move_a )
        r = p.prepare or break
        n = Renamer_.new( @y, @o, p.get_state, p.get_workorder )
        n.is_dry_run = @is_dry_run
        r = n.execute
      end while nil
      false == r and r = invite
      nil
    end

    def normalize_some_lines
      first_line = @scn.gets or fail "sanity"
      p = get_line_cleaner first_line
      @item_a = [ ]
      x = p[ first_line ] and accept x
      while (( line = @scn.gets ))
        x = p[ line ] and accept x
      end
      if @item_a.length.nonzero? then true else
        @y << "none of the #{ @scn.count } input line(s) matched #{ @use_rx }"
        invite
        false
      end
    end

    margin = '\A[* ] '
    SEP_ = '-'
    HACK_RX_ = /#{ margin }/
    rest = "(?<num>[0-9]+)(?<body>#{ SEP_ }[^\\n]+)\n?\\z"
    RAW_RX_ = /#{ margin }#{ rest }/
    CUT_RX_ = /\A#{ rest }/

    def get_line_cleaner first_line
      @use_rx = if HACK_RX_ =~ first_line
        RAW_RX_
      else
        CUT_RX_
      end
      @use_rx.method :match
    end

    def accept md
      @item_a << Item_[ * md.captures ]
      nil
    end

    class Item_

      class << self ; alias_method :[], :new end

      def initialize num, body
        @num_s = num ; @body = body
        @num_d = num.to_i
        nil
      end

      attr_reader :num_s, :num_d, :body

      attr_accessor :new_num_d

      def get_new_name_using_number num_d
        num_s = "%0#{ @num_s.length }d" % num_d
        self.class.render num_s, @body
      end

      def render
        self.class.render @num_s, @body
      end

      def self.render num_s, body
        "#{ num_s }#{ body }"
      end
    end

    class Move_

      class << self ; alias_method :[], :new end

      def initialize from_d, to_d
        @from_d, @to_d = from_d, to_d
      end

      attr_reader :from_d, :to_d

      def factor
        @factor ||= ( 1.0 * @to_d / @from_d )
      end

      def get_invalid_factor_reason
        if @from_d.zero?
          "won't divide by zero."
        elsif @to_d < 0 || @from_d < 0
          "negative numbers?"
        end
      end
    end

    class Preparer_

      def initialize y, item_a, move_a
        @pair_a = nil
        @y, @item_a, @move_a = y, item_a, move_a
      end

      attr_reader :pair_a

      def prepare
        @pair_a and fail "sanity"
        begin
          r = index or break
          scn = Basic::List::Scanner[ @move_a ]
          while (( mv = scn.gets ))
            r = move( mv ) or break
          end
        end while nil
        if false == r
          r = bork "won't procede because of the above."
        end
        r
      end

      def get_state
        @pair_a or fail "sanity"
        State_.new( @item_a, @input_num_to_idx_h )
      end

      class State_

        def initialize item_a, input_num_to_idx_h
          @item_a, @input_num_to_idx_h =
            item_a, input_num_to_idx_h
        end

        attr_reader :item_a, :input_num_to_idx_h

        def fetch_item_by_number num_d
          idx = @input_num_to_idx_h.fetch num_d
          @item_a.fetch idx
        end
      end

      def get_workorder
        @pair_a or fail "sanity"
        Workorder_.new( @pair_a )
      end

      Workorder_ = ::Struct.new :pair_a

    private

      define_method :hi, & Hi_

      def bork msg
        @y << msg
        false
      end

      def index
        begin
          r = index_num or break
        end while nil
        r
      end

      def index_num
        -> do  # #result-block
          num_to_idx_h = { } ; a = [ ]
          ok = true
          @item_a.each_with_index do |item, idx|
            did = false
            found_idx = num_to_idx_h.fetch( item.num_d ) do |d|
              did = true
              a << d
              num_to_idx_h[ d ] = idx
            end
            if ! did
              ok = false
              @y << "#{ hi 'duplicates:' }"
              @y << "  #{ @item_a[ found_idx ].render }"
              @y << "  #{ item.render }"
            end
          end
          if ok
            @input_num_to_idx_h = num_to_idx_h
            a.sort!
            @pair_a = a.map( & Pair_.method( :new ) ).freeze
          end
          ok
        end.call
      end

      class Pair_
        def initialize d0
          @d0 = d0
        end
        attr_reader :d0
        attr_accessor :d1
      end

      def move move
        -> do  # #result-block
          from_d = move.from_d ; h = @input_num_to_idx_h
          h.key? from_d or
            break bork( "no such starting number: #{ from_d }" )
          s = move.get_invalid_factor_reason and break bork s
          idx = @pair_a.index { |p| from_d == p.d0 }
          r = prepare_low( move, idx ) or break r
          r = prepare_hi( move, idx ) or break r
          true
        end.call
      end

      def prepare_low move, idx1
        d1_h = { } ; r = true ; col_a = nil
        ( 0 .. idx1 ).each do |idx|
          pair = @pair_a.fetch idx
          d1 = ( pair.d0 * move.factor ).to_i
          if d1_h[ d1 ]
            ( col_a ||= [ ] ) << d1
          else
            d1_h[ d1 ] = true
            pair.d1 = d1
          end
        end
        col_a and r = bork( "number collision - after transision, the #{
          }number(s) occur more than once - (#{ col_a * ', ' })" )
        r
      end

      def prepare_hi move, idx1
        -> do
          handle = @pair_a.fetch idx1
          ( dx = handle.d1 - handle.d0 ).zero? and
            break bork( "there was no change in the \"handle\" element" )
          ( @pair_a.length - 1 ).downto( idx1 + 1 ).each do |idx|
            pair = @pair_a.fetch idx
            pair.d1 = pair.d0 + dx  # negative dx ok , but expect it to ..
          end
          true
        end.call
      end
    end

    class Renamer_

      def initialize y, o, state, workorder
        @is_dry_run = true
        @y, @o, @state, @workorder = y, o, state, workorder
      end

      attr_writer :is_dry_run

      def execute
        if @is_dry_run
          flush
        else
          @y << "for now, only --dry-run is supported:"
          @y << "run the command with --dry-run (-n) and redirect its"
          @y << "its output to a file and run the file with `source`"
          false
        end
      end

    private

      def flush
        state = @state
        y = if @is_dry_run
          @o.method( :puts )
        else
          fail 'no'
        end
        @workorder.pair_a.reverse_each do |pair|
          item = state.fetch_item_by_number pair.d0
          name = item.get_new_name_using_number pair.d1
          y[ "git branch -m #{ item.render } #{ name }" ]
        end
        true
      end
    end
  end
end
