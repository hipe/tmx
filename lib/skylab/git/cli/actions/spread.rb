module Skylab::Git

  class CLI::Actions::Spread

    def initialize i, o, e
      @y = ::Enumerator::Yielder.new( & e.method( :puts ) )
      @snitch = Support_::Snitch_.new @y, self
      @o = o  # the output stream
      @program_name = @is_finished = nil
    end

    attr_writer :program_name

    def invoke argv
      @do_evenulate = nil
      begin
        r = parse_args( argv ) or break
        r = normalize or break
        r = work
      end while nil
      false == r and invite
      nil
    end

  private

    def invite
      @y << "see '#{ program_name } -h' for help"
      nil
    end

    def program_name
      @program_name || Git_::Lib_::CLI_program_basename[]
    end

    def build_option_parser
      @is_dry_run = false ; @from_file = nil
      @op = Git_::Library_::OptionParser.new do |op|
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

      @y << "#{ hi 'usage:' } #{ program_name } [opts] #{ NUM_NUM_ }#{ DBL_ }"

      @y << "#{ hi 'description:' }#{ <<-HERE.gsub( /^[ ]+/, ' ' )
        if you have git branches numbered like
        "01-foo-bar", "02-fiz-baz", "03-frank-banger" etc - and you say
        `spread 3 7` then 03 becomes 07, 01 becomes 02, and 02 becomes
        04. it's obvious what's happening here.

        (experimental: '#{ EL_ }' will kick every number that is
        not already even up to the next number, and so on.)\n

        HERE
      }"
      @y << "#{ hi 'options:' }"
      @op.summarize @y
      @is_finished = true
    end

    DBL_ = "\n\n".freeze
    EL_ = 'evenulate'.freeze
    NUM_NUM_ = "( <num> <num> | #{ EL_ } )"

    Hi_ = -> msg do
      @hi ||= Git_::Lib_::CLI[]::Pen::FUN::Stylify.curry[ [ :green ] ]
      @hi[ msg ]
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
        resolve_something_from_argv argv
      end.call
    end

    def resolve_something_from_argv argv
      if argv.length.nonzero? and Match_[ argv[ 0 ] ]
        argv.shift
        @do_evenulate = true
      else
        d_a = get_parsed_contiguous_integers argv
      end
      if argv.length.nonzero?
        bork "unexpected argument(s) #{ argv.inspect }"
      elsif @do_evenulate
        true
      else
        resolve_move_request_from_integers d_a
      end
    end
    Match_ = Git_::Lib_::Fuzzy_matcher[ 1, EL_ ]  # fuzzy match 'e'

    def get_parsed_contiguous_integers argv
      a = [ ]
      while argv.length.nonzero? && (( NUM_RX_ =~ argv[ 0 ] ))
        a << argv.shift.to_i
      end
      a
    end

    NUM_RX_ = /\A\d+\z/

    def resolve_move_request_from_integers d_a
      -> do
        d_a.length.zero? and break bork( "expecting #{ NUM_NUM_ }" )
        2 == (( len = d_a.length )) or break bork( "for now, need 2, had #{
          }#{ len } numbers" )
        @move_request_a = d_a.each_slice( 2 ).map do |from, to|
          Move_Request_[ from.to_i, to.to_i ]
        end
        true
      end.call
    end

    Move_Request_ = Git_::Lib_::Struct[ :from_d, :to_d ]
    class Move_Request_

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

    def normalize
      r = false
      begin
        r = get_branches_stream_line_scanner or break
        r = API_Model::Branches.from_line_scanner( r, @snitch ) or break
        @branches = r
        true
      end while nil
      false == r and @y << "could not complete request because of above."
      r
    end

    def get_branches_stream_line_scanner
      r = get_branches_stream
      r && Git_::Lib_::Scanner[ r ]
    end

    def get_branches_stream
      if @from_file
        get_branches_stream_from_file
      else
        get_branches_stream_from_git
      end
    end

    def get_branches_stream_from_file
      ::File.open @from_file, 'r'
    end

    def get_branches_stream_from_git # #hack-alert
      _i, o, _e = Git_::Library_::Open3.popen3 "git branch | cut -c 3-"
      _i.close
      if '' != (( s = _e.read ))
        bork "huh? - #{ s }"
      else
        o
      end
    end

    def work
      if @do_evenulate
        @branches.invoke :evenulate, :snitch, @snitch, :outstream, @o
      else
        @branches.invoke :spread, :snitch, @snitch, :outstream, @o,
          :move_request_a, @move_request_a
      end
    end

    module Support_
      class Snitch_  # snitches are tracked by [#fa-051]
        def initialize y, expression_agent
          @y = y
          @expression_agent = expression_agent
        end
        attr_reader :y
        def info &blk
          @y << render_line( blk )
          nil  # important
        end
        def warn &blk
          @y << "warning - #{ render_line blk }"
          nil  # important
        end
        def error &blk
          @y  << "error - #{ render_line blk }"
          false  # important
        end
        def multiline_note &blk
          @expression_agent.instance_exec @y, &blk
          nil
        end
      private
        def render_line blk
          @expression_agent.instance_exec( & blk )  # see snitches elsewhere
        end
      end
    end

    module API_Model

      Branches = Git_::Lib_::Struct[ :branch_a ]
      class Branches

        class << self
          private :new
        end

        def self.from_line_scanner scn, snitch
          -> do  # #result-block
            # we use the first line to determine whether the input list has
            # the margin that git puts there #hack-alert or is some (e.g
            # hand-written) list
            line = scn.gets or
              break( snitch.error { "there were no input lines" } )
            parse = Line_parser_[ line ]
            branch_a = [ ]
            begin
              a = parse[ line ] and branch_a << Branch_[ * a ]
            end while (( line = scn.gets ))
            branch_a.length.zero? and break snitch.error { "no lines matched" }
            allocate.instance_exec do
              initialize snitch
              init_from_branch_a branch_a
            end
          end.call
        end
        Line_parser_ = -> do
          margin = '\A[* ] ' ; sep = '-'
          rest = "(?<num>[0-9]+)(?<body>#{ sep }[^\\n]+)\n?\\z"
          hack_rx = /#{ margin }/
          raw_rx = /#{ margin }#{ rest }/
          cut_rx = /\A#{ rest }/
          -> first_line do
            match = ( hack_rx =~ first_line ? raw_rx : cut_rx ).method :match
            -> line { md = match[ line ] and md.captures }
          end
        end.call

        def invoke i, * x_a
          cls = API_Model::Actions.fuzzy_const_get i
          x_a << :branches << self << :snitch << @snitch
          cls.new( x_a ).execute
        end

        def fetch_item_by_number num_d
          idx = @number_to_idx_h.fetch num_d
          @branch_a.fetch idx
        end

        def _number_to_idx_h
          @number_to_idx_h
        end

        def _sorted_number_a
          @sorted_number_a
        end

      private

        def init_from_branch_a branch_a
          -> do  # #result-block
            a = [ ] ; num_to_idx_h = { }
            ok = true
            branch_a.each_with_index do |item, idx|
              did = false
              found_idx = num_to_idx_h.fetch( item.num_d ) do |d|
                did = true ; a << d
                num_to_idx_h[ d ] = idx
              end
              if ! did
                ok = false
                @snitch.multiline_note do |y|
                  y << "#{ hi 'duplicates:' }"
                  y << "  #{ branch_a[ found_idx ].render }"
                  y << "  #{ item.render }"
                end
              end
            end
            if ! ok then false else
              @branch_a = branch_a
              @number_to_idx_h = num_to_idx_h.freeze
              a.sort!
              @sorted_number_a = a.freeze
              self
            end
          end.call
        end

        def initialize snitch
          @snitch = snitch  # not used here but used as a parameter
          @y = snitch.y
        end
      end

      Branch_ = Git_::Lib_::Struct[ :num_s, :body, :num_d ]
      class Branch_
        def initialize num_s, body
          @num_s = num_s ; @body = body
          @num_d = num_s.to_i
          nil
        end

        def render
          self.class.render @num_s, @body
        end

        def self.render num_s, body
          "#{ num_s }#{ body }"
        end

        def get_new_name_using_number num_d
          num_s = "%0#{ @num_s.length }d" % num_d
          self.class.render num_s, @body
        end
      end

      late = { }
      define_singleton_method :const_missing do |c|
        if (( p = late[ c ] ))
          p[]
          const_defined?( c, false ) or fail "sanity - #{ c }"
          const_get c
        else
          super c
        end
      end
      define_singleton_method :[]=, & late.method( :[]= )
    end

    module API_Model

      self[ :Actions ] = -> do

        module Actions
          def self.fuzzy_const_get i
            Autoloader_.const_reduce [ i ], self
          end
        end

        Entity_ = -> client, _fields_, * field_i_a do
          :fields == _fields_ or raise ::ArgumentError
          Git_::Lib_::Basic_Fields[ :client, client,
            :absorber, :initialize,
            :field_i_a, field_i_a ]
        end

        class Branch_Mungulator_

        private

          def bork msg
            @snitch.error { msg }
            false
          end

          def flush_work
            r = false
            @work_a.each do |unit|
              r ||= true
              item = @branches.fetch_item_by_number unit.from_d
              name = item.get_new_name_using_number unit.to_d
              @outstream.puts "git branch -m #{ item.render } #{ name }"
            end
            r
          end
        end

        Work_Unit_ = Git_::Lib_::Struct[ :from_d, :to_d ]

        class Actions::Evenulate < Branch_Mungulator_

          Git_::Lib_::Funcy_globless[ self ]

          Entity_[ self, :fields, :branches, :outstream, :snitch ]

          def execute
            @work_a = determine_work_a
            flush_work
          end

          def determine_work_a
            bubble = Git_::Library_::Set.new ; work_a = [ ]
            do_number = -> d do
              is_even = ( d % 2 ).zero?
              d_ = is_even ? d : d + 1
              d_ += 2 while bubble.include?( d_ )
              bubble.add d_  # d_ is the either the new number it should have
              # or the good number it has and will continue to have,
              d_ == d or work_a << Work_Unit_[ d, d_ ]
              # but obv we only have to do work if the number chnaged.
            end
            @branches._sorted_number_a.each( & do_number )
            # failure is impossible because the set of integers is unbounded
            work_a
          end
        end

        class Actions::Spread < Branch_Mungulator_

          Git_::Lib_::Funcy_globless[ self ]

          Entity_[ self, :fields, :branches, :move_request_a,
            :outstream, :snitch ]

          def execute
            r = false
            begin
              r = determine_work or break
              r = flush_work
            end while nil
            r
          end

        private

          def determine_work
            @branch_number_to_idx_h = @branches._number_to_idx_h
            @work_a = @branches._sorted_number_a.
              map( & Work_Unit_.method( :new ) ).freeze
            scn = Git_::Lib_::Scanner[ @move_request_a ]
            r = true
            while (( move_request = scn.gets ))
              r = process_single_move_request( move_request ) or break
            end
            r
          end

          def process_single_move_request move
            -> do  # #result-block
              from_d = move.from_d
              @branch_number_to_idx_h.key? from_d or
                break bork( "no such starting number: #{ from_d }" )
              s = move.get_invalid_factor_reason and break bork s
              idx = @work_a.index{ |p| from_d == p.from_d }
              r = prepare_low( move, idx ) or break r
              r = prepare_hi( move, idx ) or break r
              true
            end.call
          end

          def prepare_low move, idx1
            d1_h = { } ; r = true ; col = nil
            ( 0 .. idx1 ).each do |idx|
              pair = @work_a.fetch idx
              d1 = ( pair.from_d * move.factor ).to_i
              if d1_h[ d1 ]
                # when a collision is detected, the number has occurred 2 times.
                ( col ||= Git_::Lib_::Box[].new ).
                  add_or_modify d1, -> { 2 }, -> i { i + 1 }
              else
                d1_h[ d1 ] = true
                pair.to_d = d1
              end
            end
            col and r = bork( "number collision - after transision, the #{
              }number(s) occur more than once - (#{ col.to_a.map do |i, d|
                if 2 == d then "#{ i }" else "#{ i } (#{ d } times)" end
              end * ', ' })" )
            r
          end

          def prepare_hi move, idx1
            -> do
              handle = @work_a.fetch idx1
              ( dx = handle.to_d - handle.from_d ).zero? and
                break bork( "there was no change in the \"handle\" element" )
              ( @work_a.length - 1 ).downto( idx1 + 1 ).each do |idx|
                pair = @work_a.fetch idx
                pair.to_d = pair.from_d + dx  # negative dx ok , but expect it to ..
              end
              true
            end.call
          end
        end
      end
    end
  end
end
