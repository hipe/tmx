module Skylab::Git

  module Models_::Branches

    Require_brazen_[]

    ::Kernel._I_AM_ONE
    class Actions::Scoot < Brazen_::Action

      @instance_description_proc = -> y do
        y << 'furloughed (used sunsetted plugins arch; no coverage at all)'
        y << "(probably just merge any outstanding work here into re-number)"
      end

    # <- 2

  class Impl___

    class Really_Basic_CLI_Client__

      def initialize argv, sin, sout, serr
        @argv = argv
        @exitstatus = ERROR_CODE_
        @stderr_IO = serr
        @y = ::Enumerator::Yielder.new( & serr.method( :puts ) )
      end

      attr_accessor :program_name

      def execute
        @do_procede = true
        Home_::Library_::OptionParser.class  # #touch
        ok = preparse_opts
        ok &&= parse_opts
        ok &&= parse_args
        ok &&= ( build_API_action.execute or invite )
        ok ? 0 : @exitstatus
      end
      def parse_opts
        build_option_parser.parse! @argv
        @do_procede
      rescue ::OptionParser::ParseError => e
        @y << e.message
        invite
        CEASE_
      end
      def hdr s
        "\e[32m#{ s }\e[0m"
      end
      def build_indenting_word_wrapper ind_s, d
        Word_Wrap_[ ind_s, d, @y ]
      end
      def when_missing_arg s
        @y << "expecting #{ s }"
        usage ; invite ; CEASE_
      end
      def when_extra_arg
        @y << "unexpected argument: #{ @argv.fetch( 1 ).inspect }"
        usage ; invite ; CEASE_
      end
      def usage
        @y << "usage: #{ usage_string }" ; nil
      end
      def invite
        @y << "see #{ say { hdr "#{ program_name } -h" } }." ; nil
      end
      def say & p
        instance_exec( & p )
      end
      def hi s
        hdr s
      end
    end

    class Client_ < Really_Basic_CLI_Client__

      def initialize( * )
        @capture_index_s = @do_remembers = nil
        @from_s = @is_dry_run = @to_s = nil
        super
        load_plugins
      end

      def init_plugins
        # we do things like aggregate the o.p options ourself later
      end

      def build_option_parser
        o = ::OptionParser.new
        o.on '--from <d>',
         "the branch will be renamed only if its incoming digit",
         "sequence when treated as an integer (that is, leading",
         "zeros disregarded) is greater than or equal to digit <d>" do |s|
           @from_s = s
        end
        o.on '--to <d>', "like --from but ceiling not floor." do |s|
          @to_s = s
        end
        o.on '--capture-index <d>',
          "if your pattern has multiple '%d' symbols,",
          "this is a required 0-indexed indicator of which one is",
          "the subject of the mutation (only 1 column at a time!)" do |s|
            @capture_index_s = s ; nil
        end

        write_plugin_option_parser_options o

        o.on '-n', '--dry-run', "dry run." do
          @is_dry_run = true
        end
        o.on '-h', '--help', "this screen" do
          render_help_screen o
        end
        o.summary_width = 24
        o.summary_indent = '    '
        o
      end

      def render_help_screen op
        us = usage_string
        @usage_header = 'usage:'
        @y << say { "#{ hdr @usage_header } #{ us }" }
        render_plugin_usage_strings
        @y << BREAK__
        @y << say { "#{ hdr 'description:' }" }
        w = build_indenting_word_wrapper '  ', 80
        w << "re-numbers particular git branches of yours whose names"
        w << "match a particular pattern."
        w << BREAK__
        w << "<pattern> matches strings that contain digit sequences with a"
        w << "certain placement indicated by the pattern: the pattern"
        w << "\"foo-#{ PD_ }-bar\" matches \"foo-123-bar\", \"foo-02-bar\" et"
        w << "cetera."
        w << BREAK__
        w << "for each of your git branches whose name matches that pattern"
        w << "(and ergo has a digit sequence in it), rename that branch such"
        w << "that it has <amount> (an integer) added or subtracted to the"
        w << "digit sequence as indicated by the presence of the '+' or '-'"
        w << "respectively."
        w << BREAK__
        w << "the <pattern> string must contain '#{ PD_ }' (the quotes not"
        w << "being part of this symbol) somewhere. this symbol represents"
        w << "the sequence of digits that will be matched in your branch"
        w << "names and subsequently replaced with the new number when the"
        w << "branch is renamed."
        w << BREAK__
        w << "'*' may also be used in the pattern, which will match any"
        w << "of zero or more characters at that point in the branch name."
        w << "take care to protect your pattern string from shell expansion"
        w << "by for example surrounding it in single-quotes."
        w << BREAK__
        w << "your argument terms may occur in any order provided of course"
        w << "that each argument immediately follows the any (sic) symbol or"
        w << "option that defines it."
        w << "(this is only possible because there is no overlap between"
        w << "what could be interpreted as a pattern and what could be"
        w << "interpreted as an expression of amount (whether or not you"
        w << "put the optional space between the plus or minus sign and"
        w << "the number).)"
        w << BREAK__
        w << "we would offer examples but it's more fun if you just try"
        w << "it a bunch of times with the --dry-run option on."
        w << BREAK__
        @y << say { "#{ hdr 'about digit sequences with leading zeros:' }" }
        w << "this was designed from the start to do the right thing in"
        w << "regards to numerical sequences that are written as"
        w << "\"fixed width\"-style, with leading zeroes."
        w << "but behavior is pursuant to both input data and would-be"
        w << "output data, and may result in unresolvable ambiguity."
        w << "this will abort early and loudly if there is any ambiguity"
        w << "in the set of changes it would otherwise attempt to make."
        w << BREAK__
        w << "there is currently no option to indicate which of these"
        w << "naming schemes to use explicitly but this is under"
        w << "consideration. (we expect 'leading zero' style to be preferred,"
        w << "but even so, if all the numbers in a set of branch names have"
        w << "the same number of digits, then this preference is not"
        w << "expressed by the data and we don't want to assume it (yet).)"
        w << BREAK__ ; w.flush
        @y << say { "#{ hdr 'options:' }" }
        op.summarize @y
        @do_procede = false ; @exitstatus = 0
      end ; BREAK__ = ''.freeze

      def usage_string
        a = [] ; call_plugin_listeners :on_render_tiny_switches, a
        "#{ program_name } #{ a.length.nonzero? and "#{ a * ' ' } " }#{
          }[-n] [ --from <d> | --to <d> ] <pattern> (+|-) <amount>"
      end

      def render_plugin_usage_strings
        usage_yielder_for_plugin = -> do
          _indent = ' ' * ( @usage_header.length + 1 )
          margin = "#{ _indent }#{ program_name } "
          y = ::Enumerator::Yielder.new do |str|
            @y << "#{ margin }#{ str }"
          end
          usage_yielder_for_plugin = -> { y } ; y
        end
        call_plugin_listeners :on_render_usage_lines do |i|
          @plugin_conduit_h.fetch( i ).
            plugin.on_render_usage_lines usage_yielder_for_plugin[]
        end
      end

      def preparse_opts
        @amount_d = Parse_plus_or_minus_digit__[ @argv ]
        true
      end

      def parse_args
        ok = parse_pattern_arg
        ok && ensure_amount_arg
      end

      def parse_pattern_arg
        @argv.length.zero? and call_plugin_listeners :on_no_arguments, @argv
        case @argv.length <=> 1
        when -1 ; when_missing_arg '<pattern>'
        when  0 ; when_good_arg
        when  1 ; when_extra_arg
        end
      end

      def when_good_arg
        @pattern_s = @argv.shift
        call_plugin_listeners :on_pattern_string_received, @pattern_s
        PROCEDE_
      end

      def ensure_amount_arg
        @amount_d or when_missing_arg '(+|-) <amount>'
      end

      def build_API_action
        API_Action__.new do |a|
          a.amount_d = @amount_d
          a.capture_index_s = @capture_index_s
          a.from_s = @from_s
          a.is_dry_run = @is_dry_run
          a.pattern_s = @pattern_s
          a.program_name = @program_name
          a.to_s = @to_s
          a.info_line_yielder = @y
        end
      end
    end

    Parse_plus_or_minus_digit__ = -> a do
      sign_rx = /\A(?:\+|(-))\z/
      amt_rx = /\A(?:(\+)|(-)|)(\d+)\z/
      d = a.length
      while d.nonzero?
        amt_rx =~ a.fetch( d -= 1 ) or next
        multiplier = if $~[1] then 1 elsif $~[2] then -1 end
        base = $~[3].to_i
        dd = consumed_d = d
        while dd.nonzero?  # easter egg
          if sign_rx =~ a.fetch( dd -= 1 )
            consumed_d = dd
            multiplier ||= 1
            if $~[1]
              multiplier *= -1
            end
          else
            break
          end
        end
        multiplier or next
        r = multiplier * base
        a[ consumed_d .. d ] = []
        break
      end
      r
    end

    class API_Action__
      def initialize
        @capture_index_d = @from_d = @to_d = nil
        yield self
      end
      attr_writer :amount_d, :capture_index_s, :from_s, :is_dry_run,
        :pattern_s, :program_name, :to_s
      def info_line_yielder= x
        @y = x
      end
      def execute
        ok = parse_args
        ok && exec_when_args_OK
      end
    private
      def parse_args
        @error_count = 0
        rslv_cap_idx ; rslv_from ; rslv_pattern ; rslv_to
        @error_count.zero?
      end
      def rslv_cap_idx
        if @capture_index_s
          @capture_index_d = rslv_some_non_neg_int @capture_index_s do
            "'capture index'"
          end
          @capture_index_s = nil
        end
      end
      def rslv_from
        if @from_s
          @from_d = rslv_some_non_neg_int @from_s do "'from'" end
          @from_s = nil
        end
      end
      def rslv_to
        if @to_s
          @to_d = rslv_some_non_neg_int @to_s do "'to'" end
          @to_s = nil
        end
      end
      def rslv_some_non_neg_int s
        md = INT_RX__.match s
        if md
          if md[1]
            whine "#{ yield } must be positive integers (had #{ s })"
          else
            s.to_i
          end
        else
          whine "#{ yield } must be a positive integer: #{ s.inspect }"
        end
      end
      INT_RX__ = /\A(-)?\d+\z/
      def rslv_pattern
        @pattern = Parse_Pattern__.new( @pattern_s,
          method( :parse_error_string_from_pattern_parse ) ).execute
      end
      def parse_error_string_from_pattern_parse s
        whine s
      end
      def whine s
        @error_count += 1 ; @y << s ; nil
      end
      def exec_when_args_OK
        @pattern.amount_d = @amount_d
        @pattern.capture_index_x = @capture_index_d
        @pattern.is_dry_run = @is_dry_run
        @pattern.set_begin_and_end @from_d, @to_d
        Rename__.new do |rn|
          rn.info_yielder = @y
          rn.is_dry_run = @is_dry_run
          rn.pattern = @pattern
          rn.system_conduit = begin require 'open3' ; ::Open3 end
        end.execute
      end
    end

    PD_ = '%d'.freeze

    class Parse_Pattern__
      def initialize pattern_s, error_p
        @error_p = error_p ; @pattern_s = pattern_s
      end
      def execute
        produce_sexp
        process_sexp
      end
    private
      def produce_sexp
        @sexp = []
        @scn = begin require 'strscan' ; ::StringScanner end.new @pattern_s
        while ! @scn.eos?
          len = @sexp.length
          pln = @scn.scan( PLAIN_RX__ ) and @sexp << Sexp__[ :plain, pln ]
          @scn.skip( D_RX__ ) and @sexp << D__
          @scn.skip( STAR_RX__ ) and @sexp << STAR__
          len == @sexp.length and _this_will_never_happen_
        end ; nil
      end
      PLAIN_RX__ = /(?:(?!(?:\*+|#{ PD_ })).)+/
      D_RX__ = /#{ PD_ }/
      STAR_RX__ = /\*+/
      Sexp__ = ::Struct.new :name, :string
      D__ = Sexp__.new :percent_d
      STAR__ = Sexp__.new :kleene_star
      def process_sexp
        @d_count = 0 ; @i_a = [] ; @s_a = [] ; @rx_s_a = [ '\A' ]
        @sexp.each do |sexp|
          i, s = sexp.to_a
          send i, * s
        end
        conclude
      end
      def kleene_star
        @s_a << '*' ; @rx_s_a << '(.*)' ; @i_a << :glob ; nil
      end
      def percent_d
        @d_count += 1
        @s_a << PD_ ; @rx_s_a << '(\d+)' ; @i_a << :num_seq ; nil
      end
      def plain s
        @s_a << s ; @rx_s_a << "(#{ ::Regexp.escape s })" ; @i_a << :lit ; nil
      end
      def conclude
        @rx_s_a << '\z' ; @rx_s = @rx_s_a * '' ; @rx_s_a = nil
        @s = ( @s_a * '' ).freeze ; @s_a = nil ; @i_a.freeze
        if @d_count.zero?
          when_d_count_zero
        else
          conclude_when_valid
        end
      end
      def when_d_count_zero
        @error_p[ "your pattern string must contain '#{ PD_ }' in it #{
          }somewhere: #{ @s.inspect }" ]
      end
      def conclude_when_valid
        Pattern__.new ::Regexp.new( @rx_s ), @i_a, @s
      end
    end

    class Pattern__  # think of this as a map/reduce translating function
      # that is also shamelessly shoehorned into a mutable request structure
      def initialize rx, i_a, s
        @rx = rx ; @s = s
        @pat_mtx = Pattern_Metrics__.new i_a, (
          i_a.each_with_index.reduce [] do |m, (i, d)|
            :num_seq == i and m << d ; m
          end.freeze ) ; nil
      end
      attr_reader :begin, :end, :rx, :s
      attr_accessor :amount_d, :capture_index_x
      attr_accessor :is_dry_run, :scheme_i
      def set_begin_and_end d, d_
        @begin = d ; @end = d_ ; nil
      end
      def as_normalized_input_string
        @s
      end
      def numeric_sequence_count
        @pat_mtx.numeric_seq_count
      end
      def match x_s
        md = @rx.match( x_s ) and bld_match( md )
      end
    private
      def bld_match md
        Match__.new md.captures.freeze, @pat_mtx
      end
    public
      def range_includes d  # could probably be sped up
        ok = true  # with a pre-arranged proc but why?
        if @begin
          @begin > d and ok = false
        end
        if @end && ok
          @end < d and ok = false
        end
        ok
      end
    end

    class Pattern_Metrics__
      def initialize i_a, d_a
        @d_a = d_a ; @i_a = i_a
        @num_seq_cnt = @i_a.reduce 0 do |m, i|
          :num_seq == i ? m + 1 : m
        end
        @reverse_h = ::Hash[ @d_a.each_with_index.to_a ] ; nil
      end
      def numeric_seq_count
        @num_seq_cnt
      end
      def numerical_sequence_cap_idxs
        @d_a
      end
      def translate_long_index_to_short_index long_d
        @reverse_h.fetch long_d
      end
    end

    class Match__
      def initialize s_a, pat_mtx
        @initial_name_s = ( s_a * EMPTY_S_ ).freeze
        @num_cap_a = []
        @pat_metrics = pat_mtx
        @s_a = s_a
      end
      attr_reader :initial_name_s, :s_a
      attr_accessor :new_name_s
      def write_info_at_index d, & p
        d_ = translate_index_to_num_cap_index d
        _info = @num_cap_a.fetch d_ do
          @num_cap_a[ d_ ] = Capture__.new d, @s_a.fetch( d )
        end
        p[ _info ] ; nil
      end
      def length_of_as_string
        @s_a.reduce( 0 ) { |m, x| m += x.length }
      end
      def capture_indexes_of_numerical_sequences
        @pat_metrics.numerical_sequence_cap_idxs
      end
      def num_cap_at_num_cap_index idx
        @num_cap_a.fetch idx
      end
      def translate_index_to_num_cap_index idx
        @pat_metrics.translate_long_index_to_short_index idx
      end
    end

    Capture__ = ::Struct.new :index_d, :s,
      :after_change_d, :after_change_s, :as_d, :has_leading_zeroes

    class Rename__
      def initialize
        yield self
      end
      attr_writer :info_yielder, :is_dry_run, :pattern, :system_conduit
      def execute
        @uow = do_early_validation
        @uow &&= build_rename_units_of_work
        @uow && exec_with_units_of_work
      end
    private
      def do_early_validation
        Validate_capture_index__.new( @pattern, @info_yielder ).execute
      end
      def build_rename_units_of_work
        Build_rename_units_of_work__.
          new( @system_conduit, @pattern, @info_yielder ).execute
      end
      def exec_with_units_of_work
        Execute_units_work__.new( @system_conduit, @uow,
          @pattern, @info_yielder ).execute
      end
    end

    class Validate_capture_index__
      def initialize pat, y
        @cap_idx_d = pat.capture_index_x ; @pat = pat ; @y = y
      end
      def execute
        idx = rslv_any_valid_capture_index
        idx and @pat.capture_index_x = idx
      end
      def rslv_any_valid_capture_index
        @num_seq_cnt = @pat.numeric_sequence_count
        case @num_seq_cnt <=> 1
        when -1 ; when_no_num_seq
        when  0 ; when_one_num_seq
        when  1 ; when_many_num_seq
        end
      end
      def when_no_num_seq
        @y << "pattern has no numeric sequence in it, #{
          }aborting: '#{ @pat.as_normalized_input_string }'"
        CEASE_
      end
      def when_one_num_seq
        @cap_idx_d ? ( @cap_idx_d.zero? ? 0 : when_bad_capture_index ) : 0
      end
      def when_bad_capture_index
        @y << "bad capture index: #{ @cap_idx_d } - #{
          }there is only one numeric sequence in the pattern"
        CEASE_
      end
      def when_many_num_seq
        if @cap_idx_d
          when_many_num_seq_and_one_cap_index
        else
          when_missing_required_capture_index
        end
      end
      def when_missing_required_capture_index
        @y << "your pattern has #{ @num_seq_cnt } #{
          }numeric sequence symbols in it ('#{
           }#{ @pat.as_normalized_input_string }')."
        @y << "you must indicate which one represents the field to mutate #{
          }with a 'capture index'."
        CEASE_
      end
      def when_many_num_seq_and_one_cap_index
        @range = 0 .. @num_seq_cnt - 1
        if @range.include? @cap_idx_d then @cap_idx_d else when_outside end
      end
      def when_outside
        @y << "your capture index must be between 0 and #{ @range.end } #{
          }for that pattern (had #{ @cap_idx_d })."
        CEASE_
      end
    end

    class Build_rename_units_of_work__
      def initialize system_conduit, pattern, info_yielder
        @y = info_yielder
        @pattern = pattern
        @system_conduit = system_conduit
      end
      def execute
        @scn = get_git_branch_name_stream
        @scn && exec_with_git_branch_name_stream
      end
    private
      def get_git_branch_name_stream
        Get_git_branch_name_scanner__.
          new( @system_conduit, @y ).execute
      end
      def exec_with_git_branch_name_stream
        @uow_a = [] ; scn = @scn ; @counts = Counts__.new
        while (( s = scn.gets ))
          @counts.seen += 1
          @match = @pattern.match s
          @match and process_match
        end
        @counts.matched.zero? ? when_zero : @uow_a
      end
      def process_match
        s_a = @match.s_a ; @counts.matched_pattern += 1
        @match.capture_indexes_of_numerical_sequences.each do |d|
          s = s_a.fetch d
          @match.write_info_at_index d do |info|
            if ZERO__ == s.getbyte( 0 )
              info.has_leading_zeroes = true
            end
            info.as_d = s.to_i
          end
        end
        add_match_if_it_is_in_range ; nil
      end ; ZERO__ = '0'.getbyte 0

      def when_zero
        @counts.describe_when_zero_matches @y,
          method( :say_pat ), method( :say_range )
        CEASE_
      end
      def say_pat
        " \"#{ @pattern.s }\" (regex was: #{ @pattern.rx.inspect })"
      end
      def say_range d
        bg = @pattern.begin ; nd = @pattern.end
        _s = if bg
          if nd then "within the range #{ bg }-#{ nd }"
          else "less than or equal to #{ d }" end
        else "greater than or equal to #{ d }" end
        "#{ 1 == d ? 'was' : 'were' } #{ _s }"
      end

      def add_match_if_it_is_in_range
        cap = @match.num_cap_at_num_cap_index @pattern.capture_index_x
        _is_inside = @pattern.range_includes cap.as_d
        if _is_inside
          @counts.matched += 1
          @uow_a << @match
        else
          @counts.outside_of_range += 1
        end ; nil
      end
    end

    class Counts__
      def initialize
        @matched = @matched_pattern = @outside_of_range = @seen = 0
      end
      attr_accessor :matched, :matched_pattern, :outside_of_range, :seen
      def describe_when_zero_matches y, p_p, r_p
        yy = []
        yy << "of the #{ @seen } branches "
        if @matched_pattern.zero?
          yy << "none of them matched the pattern#{ p_p[] }."
        else
          d = @outside_of_range
          yy << "#{ @matched_pattern } of them matched the pattern, #{
            }but none of that/those #{ d } #{ r_p[ d ] }."
        end
        y << ( yy * '' ) ; CEASE_
      end
    end

    class Get_git_branch_name_scanner__
      def initialize sc, y
        @system_conduit = sc ; @info_yielder = y
      end
      def execute
        @call = get_git_branch_system_call
        peek_s = @call.gets_chopped_output_line
        peek_s ? get_good_git_branch_name_stream( peek_s ) : bad_call
      end
      def get_git_branch_system_call
        System_Call__.new do |sc|
          sc.system_conduit = @system_conduit
          sc.cmd_s_a = [ GIT_EXE_, 'branch' ]
        end
      end
      def bad_call
        while (( s = @call.gets_chopped_errput_line ))
          @info_yielder << s
        end
        @info_yielder << "(had exitstatus #{ @call.exitstatus })"
        CEASE_
      end
      def get_good_git_branch_name_stream peek_s
        p = -> do
          p = -> { @call.gets_chopped_output_line }
          peek_s
        end
        filter = -> s do
          PORCELAIN_HACK_TRIM_RX__.match( s )[ 0 ]
        end

        Common_::MinimalStream.by do
          s = p[]
          if s
            filter[ s ]
          end
        end

      end ; PORCELAIN_HACK_TRIM_RX__ = /(?<=\A[ *] ).+\z/
    end

    class System_Call__
      def initialize
        yield self
        _, @o, @e, @w = @system_conduit.popen3( * @cmd_s_a )
      end
      attr_accessor :cmd_s_a, :system_conduit
      def gets_chopped_errput_line
        s = @e.gets and s.chop!
      end
      def gets_chopped_output_line
        s = @o.gets and s.chop!
      end
      def exitstatus
        @w.value.exitstatus
      end
    end

    class Execute_units_work__
      def initialize sc, uow, pat, y
        @observers = obs = [] ; @pat = pat ; @sc = sc ; @uow = uow ; @y = y
        obs << Widest_Name__.new
        obs << Existing_Names__.new
        obs << New_Number_Numberer__.new( pat )
        obs << Capture_String_Width_Distribution__.new( pat )
        obs << Capture_String_Scheme_Distribution__.new( pat )
      end
      def execute
        ok = first_pass
        ok && second_pass
      end
    private
      def first_pass
        @uow.each do |match|
          @observers.each do |obs|
            obs.see match
          end
        end
        @summary = Observation_Summary__.new
        @observers.each do |obs|
          obs.flushback @summary
        end
        resolve_scheme
      end
      def resolve_scheme
        @pat.scheme_i = Infer_scheme__.new( @pat, @uow, @summary, @y ).execute
      end
      def second_pass
        Second_pass__.new( @sc, @pat, @uow, @summary, @y ).execute
      end
    end

    class Observation_Summary__
      attr_accessor :cap_string_width_dist_h,
        :existing_name_set, :largest_new_number,
        :scheme_distribution, :widest_branch_name_length
      def any_exist_with_leading_zeros
        @scheme_distribution.leading.length.nonzero?
      end
      def all_have_uniform_width
        1 == @cap_string_width_dist_h.length
      end
    end

    class Widest_Name__
      def initialize
        @widest_branch_name_d = 0
      end
      def see match
        d = match.length_of_as_string
        @widest_branch_name_d < d and @widest_branch_name_d = d ; nil
      end
      def flushback x
        x.widest_branch_name_length = @widest_branch_name_d ; nil
      end
    end

    class Existing_Names__
      def initialize
        @set = begin require 'set' ; ::Set end.new
      end
      def see match
        @set.add? match.initial_name_s ; nil
      end
      def flushback x
        x.existing_name_set = @set
      end
    end

    class Capture_String_Width_Distribution__
      def initialize pat
        @cap_idx_d = pat.capture_index_x ; @h = ::Hash.new { |h, k| h[k] = [] }
      end
      def see match
        cap = match.num_cap_at_num_cap_index @cap_idx_d
        @h[ cap.s.length ] << cap.s ; nil
      end
      def flushback x
        x.cap_string_width_dist_h = @h ; nil
      end
    end

    class Capture_String_Scheme_Distribution__
      def initialize pat
        @cap_idx_d = pat.capture_index_x ; @schemes = Schemes__[ [], [] ]
      end
      def see match
        cap = match.num_cap_at_num_cap_index @cap_idx_d
        @schemes[ cap.has_leading_zeroes ? :leading : :unsure ] << cap.s ; nil
      end
      def flushback x
        x.scheme_distribution = @schemes ; nil
      end
    end ; Schemes__ = ::Struct.new :leading, :unsure

    class New_Number_Numberer__
      def initialize pat
        @largest_new_number = 0
        @amt_d = pat.amount_d ; @cap_idx_d = pat.capture_index_x
      end
      def see match
        cap = match.num_cap_at_num_cap_index @cap_idx_d
        new_number = cap.as_d + @amt_d
        cap.after_change_d = new_number
        @largest_new_number < new_number and @largest_new_number = new_number
        nil
      end
      def flushback x
        x.largest_new_number = @largest_new_number
      end
    end

    class Infer_scheme__
      def initialize pat, uow, summary, y
        @pat = pat ; @uow = uow ; @summary = summary ; @y = y
      end
      def execute
        if @summary.any_exist_with_leading_zeros
          if @summary.all_have_uniform_width
            :use_leading_zeros_scheme
          else
            complain_about_non_uniform_width
          end
        elsif @summary.all_have_uniform_width
          resolve_a_scheme_by_looking_into_the_future
        else
          :use_jagged_scheme
        end
      end
    private
      def resolve_a_scheme_by_looking_into_the_future
        # all are of uniform width, none exist with leading zeroes.
        # there is ambiguity in what is the desired behavior unless all of
        # the resultant names are of uniform width *and* of the same width
        # as the current (uniform) width!
        @cap_idx = @pat.capture_index_x
        @new_h = ::Hash.new { |h, k| h[k] = [] }
        @old_h = @summary.cap_string_width_dist_h
        @uow.each do |match|
          cap = match.num_cap_at_num_cap_index @cap_idx
          d = cap.after_change_d
          num = Number_of_digits_in_integer_[ d ]
          @new_h[ num ] <<  d
        end
        case 1 <=> @new_h.length
        when -1 ; when_non_uniform_width_in_new_h
        when  0 ; when_uniform_width_in_new_h
        end
      end

      def when_uniform_width_in_new_h
        if @old_h.keys.first == @new_h.keys.first
          :use_leading_zeros_scheme  # or jagged. this is just grease
        else
          when_two_non_uniform_uniforms
        end
      end

      def when_non_uniform_width_in_new_h
        ww = build_word_wrapper
        describe_uniform_incoming_dist ww
        describe_non_uniform_new_dist ww
        describe_ambiguity ww ; ww.flush ; CEASE_
      end

      def when_two_non_uniform_uniforms
        ww = build_word_wrapper
        describe_uniform_incoming_dist ww
        describe_uniform_new_dist ww
        describe_ambiguity ww ; ww.flush ; CEASE_
      end

      def describe_uniform_incoming_dist y
        y << "the incoming numeric sequences are all #{
          }#{ @old_h.keys.fetch( 0 ) } char(s) wide#{
           }#{ say_or_dont_say_prev_num_seq }." ; nil
      end

      def say_or_dont_say_prev_num_seq
        " (#{ ellipsify_items @old_h.first.last })"
      end

      def describe_non_uniform_new_dist y
        y << "but the new numerical sequences would have a variety of #{
          }widths#{ say_or_dont_say_non_uniform_new_num_seq }." ; nil
      end

      def describe_uniform_new_dist y
        y << "but the new numerical sequences would all be of a different #{
          }width#{ say_or_dont_say_uniform_new_num_seq }." ; nil
      end

      def say_or_dont_say_non_uniform_new_num_seq
        s, s_ = @new_h.keys[ 0, 2 ].map { |k| @new_h[ k ].first }
        " (e.g #{ s.inspect }, #{ s_.inspect })"
      end

      def say_or_dont_say_uniform_new_num_seq
        " (e.g #{ ellipsify_items @new_h.first.last })"
      end

      def describe_ambiguity y
        y << "hence we can't infer whether to use leading zeros #{
          }(if applicable) in the new names." ; nil
      end

      def ellipsify_items s_a
        Ellipsify_items_[ 3, s_a ]
      end

      def build_word_wrapper
        Word_Wrap_[ nil, 65, @y ]
      end
    end

    class Second_pass__
      def initialize sc, pat, uow, summary, y
        @amount_d = pat.amount_d
        @cap_idx = pat.capture_index_x
        @name_collision_s_a = nil
        @name_scheme_i = pat.scheme_i
        @occupied_set = summary.existing_name_set
        @pat = pat ; @summary = summary
        @system_conduit = sc ; @uow = uow  ; @y = y
      end
      def execute
        prepare_name_builder
        @uow.each do |match|
          @match = match  # be careful
          @cap = @match.num_cap_at_num_cap_index @cap_idx
          send @name_scheme_i
        end
        if @name_collision_s_a
          when_name_collsion
        else
          flush_to_VCS
        end
      end
    private
      def prepare_name_builder
        send :"prepare_name_builder_when_#{ @name_scheme_i }"
      end
      def prepare_name_builder_when_use_leading_zeros_scheme
        d = Number_of_digits_in_integer_[ @summary.largest_new_number ]
        @fmt = "%0#{ d }d" ; nil
      end
      def use_jagged_scheme
        @cap.after_change_s = "#{ some_new_integer }"
        try_new_name ; nil
      end
      def use_leading_zeros_scheme
        @cap.after_change_s = @fmt % some_new_integer
        try_new_name ; nil
      end
      def some_new_integer
        @cap.as_d + @amount_d
      end
      def try_new_name
        s = build_some_new_name
        if @occupied_set.include? s
          (( @name_collision_s_a ||= [] )) << s
        else
          @match.new_name_s = s
        end ; nil
      end
      def build_some_new_name
        s_a = @match.s_a ; y = ::Array.new s_a.length ; idx = @cap.index_d
        ( 0...idx ).each do |d|
          y[ d ] = s_a.fetch d
        end
        y[ idx ] = @cap.after_change_s
        ( idx + 1 ... s_a.length ).each do |d|
          y[ d ] = s_a.fetch d
        end
        y * EMPTY_S_
      end
      def when_name_collsion
        @y << "the following name(s) would be overwritten by the move, #{
          }aborting: #{ Ellipsify_items_[ 5, @name_collision_s_a ] }"
        CEASE_
      end
      def flush_to_VCS
        Flush_to_VCS__.new @system_conduit, @uow, @y do |f|
          f.col_A_width = @summary.widest_branch_name_length
          f.is_dry_run = @pat.is_dry_run
        end.execute
      end
    end

    class Flush_to_VCS__
      def initialize system_conduit, uow, y
        @col_A_width = @is_dry_run = nil
        @uow = uow ; @y = y
        yield self
        @system_conduit = @is_dry_run ? bld_mock_sys_cond : system_conduit
        init_col_A_p
      end
      attr_accessor :col_A_width, :is_dry_run
    private
      def bld_mock_sys_cond
        Dry_Run_Sys_Cond_Mock_.new
      end
      def init_col_A_p
        if @col_A_width
          fmt = "%-#{ @col_A_width }s"
          @col_A_p = -> s { fmt % s }
        else
          @col_A_p = -> s { s }
        end ; nil
      end
    public
      def execute
        @count = 0
        ok = commit_each_unit_of_work
        ok && conclude
      end
    private
      def commit_each_unit_of_work
        ok = true
        @uow.each do |match|
          @count += 1
          s = match.initial_name_s ; s_ = match.new_name_s
          ( s && s.length.nonzero? && s_ && s_.length.nonzero? ) or self._STOP_
          @y << say_pretty_line( s, s_ )
          ok = commit_with_system s, s_
          ok or break
        end
        ok
      end
      def conclude
        @y << "finished renaming #{ @count } #{
          }branch#{ 'es' if 1 != @count }#{ ' (dryly)' if @is_dry_run }."
        PROCEDE_
      end
      def say_pretty_line s, s_
        "#{ GIT_EXE_ } branch -m  #{ @col_A_p[ s ] }  #{ s_ }"
      end
      def commit_with_system s, s_
        @i, @o, @e, @w = @system_conduit.
          popen3 GIT_EXE_, 'branch', '-m', s, s_
        s = @o.gets
        if s
          begin
            @y << "(from real git stdout: #{ s.chop! })"
            s = @o.gets
          end while s
        end
        while (( s = @e.gets ))
          @y << "(from stderr of git: #{ s.chop! })"
        end
        es = @w.value.exitstatus
        if es.zero?
          PROCEDE_
        else
          @y << "(got unexpected exitstatus from git: #{ es })"
          CEASE_
        end
      end
    end

    class Dry_Run_Sys_Cond_Mock_

      def popen3 * a
        [
          nil,
          Common_::THE_EMPTY_MINIMAL_STREAM,
          Common_::THE_EMPTY_MINIMAL_STREAM,
          WAIT__,
        ]
      end

      class Wait__
        def initialize es
          @value = Value__.new es
        end
        attr_reader :value
        Value__ = ::Struct.new :exitstatus
      end

      WAIT__ = Wait__.new 0
    end

    Number_of_digits_in_integer_ = -> d do
      if ::Fixnum === d
        0 > d and d *= -1  # we don't count any '-'
        num = 1 ; num += 1 while (( d /= 10 )).nonzero?
        num
      end
    end

    Ellipsify_items_ = -> d, s_a do
      case d <=> s_a.length
      when -1 ; "#{ s_a[ 0, d - 1 ].map( & :inspect ) * ', ' } [..]"
      when  0, 1 ; "#{ s_a.map( & :inspect ) * ', ' }"
      end
    end

    # ~ plugins setup

    class Client_

      if false
      Home_.lib_.plugin::Host[ self ]

      o = build_mutable_callback_tree_specification
      o.default_pattern :listeners
      o << :on_build_option_parser
      o << :on_render_tiny_switches
      o << :on_render_usage_lines
      o << :on_no_arguments
      o << :on_pattern_string_received
      o.end

      def plugin_box_module
        Plugins__
      end

      plugin_conduit_class
      class Plugin_Conduit
        def stderr_IO
          up.stderr_IO
        end
      end
      def stderr_IO
        @stderr_IO
      end
      end
    end

    Autoloader_[ self, ::File.dirname( __FILE__ ) ]
    Autoloader_[ Plugins__ = ::Module.new ]

    # ~ plugins

    class Plugins__::Memory

      def initialize host
        @kernel = nil
        @y_IO = host.stderr_IO
        @y = host.stderr_line_yielder
      end

      def dotfile
        DOTFILE__
      end
      DOTFILE__ = '~/.tmx/git-scoot'.freeze

      def on_render_tiny_switches y
        y << '[-a]'  # not scalable
      end

      def on_build_option_parser op
        op.on '--add-to-', "\"remember\" the pattern for future re-use. #{
          }on subsequent", "invocations if a pattern is not provided #{
           }any pattern in", "\"memory\" will be used. (experimental, #{
            }writes to", "#{ dotfile }. will write to file regardless of #{
             }-n", "flag, which is a feature.)" do
          engage
          do_write!
        end
      end

      def on_no_arguments a
        engage
        on_no_arguments a
      end

      def on_pattern_string_received s
      end

    private
      def engage
        require self.class.dir_path
        init
      end
      Autoloader_[ self ]
    end

    # ~ general small support

    Word_Wrap_ = -> ind_s, col_d, y do
      Home_.lib_.word_wrap.curry ind_s, col_d, y
    end

    if false  # NOTE we can review all of these
    CEASE_ = false
    GIT_EXE_ = 'git'.freeze
    EMPTY_S_ = ''.freeze
    ERROR_CODE_ = 4
    PROCEDE_ = true
    SILENT_ = nil
    end
  end
# -> 2
    end
  end
end
