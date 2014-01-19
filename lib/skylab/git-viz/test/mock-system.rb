module Skylab::GitViz

  module TestSupport

    module Mock_System

      def self.[] user_mod
        user_mod.module_exec do
          extend Module_Methods__
          include Instance_Methods__ ; nil
        end
      end

      module Instance_Methods__
      private

        def mock_system_conduit
          _pn = get_system_command_manifest_pn
          rslv_some_cached_system_conduit_for_pathname _pn
        end

        def get_system_command_manifest_pn
          fixtures_module.dir_pathname.join 'system-commands.manifest'
        end

        def rslv_some_cached_system_conduit_for_pathname pn
          fixtures_module.module_exec do
            @mock_system_conduit_cache ||= Mock_System_Conduit_Cache_.
              new self
          end.resolve_some_cached_conduit_for_pn pn
        end

        def fixtures_module
          self.class.fixtures_mod
        end
      end

      module Module_Methods__
        def fixtures_mod
          send( :nearest_test_node )::Fixtures  # covered
        end
      end

      class Mock_System_Conduit_Cache_
        def initialize fixtures_module
          @cache_h = ::Hash.new do |h, pn|
            h[ pn ] = Mock_System_Conduit_.new pn
          end
          @fixtures_mod = fixtures_module
        end
        def resolve_some_cached_conduit_for_pn pn
          @cache_h[ pn ]
        end
      end

      class Mock_System_Conduit_
        def initialize pn
          @h = {} ; pn.open 'r' do |fh|
            Parse_Manifest_.new( fh, method( :accpt_line ) ).execute
          end
          @manifest_dirname_pn = pn.dirname ; nil
        end
      private
        def accpt_line cmd_s, iam_s_a
          cmd = Stored_Command_.new cmd_s.freeze, iam_s_a
          ( @h.fetch cmd.cmd_s do |k|
            @h[ k ] = []
          end ) << cmd ; nil
        end
      end

      class Parse_Manifest_
        def initialize fh, p  # NOTE mutates filehandle to be a peeking scanner
          GitViz::Lib_::Basic[]::List::Scanner::With[ fh, :peek ]
          @accept_line_p = p ; @fh = fh
        end
        def execute
          line = @fh.gets or fail "empty command manifest file: #{ fh.path }"
          begin
            parse_entry line
          end while (( line = @fh.gets )) ; nil
        end
      private
        def parse_entry line
          line.chop!
          @_chopped_s_a = []  # be careful, we are iterate over many of these
          key_s, any_rest_of_line = line.split RECORD_SEPARATOR__, -1
          any_rest_of_line and @_chopped_s_a << any_rest_of_line
          parse_any_sublines
          @_chopped_s_a.length.zero? and fail say_no_content line
          @accept_line_p[ key_s, @_chopped_s_a ] ; nil
        end
        RECORD_SEPARATOR__ = "\t".freeze
        def parse_any_sublines
          while true
            (( line = @fh.peek )) or break
            if NEWLINE__ == line.getbyte( 0 )  # here is how we skip empty lines
              @fh.gets
              next
            end
            SPACE__ == line.getbyte( 0 ) or break
            @fh.gets
            @_chopped_s_a << line.chop!  # we live dangerously
          end ; nil
        end
        SPACE__ = ' '.getbyte 0 ; NEWLINE__ = "\n".getbyte 0
        def say_no_content line
          "must be followed by either a tab characer or \"sub-lines\":#{
            }#{ line.inspect }"
        end
      end

      class Stored_Command_
        def initialize cmd_s, iam_s_a
          @cmd_s = cmd_s ; @did_parse = false
          @has_out_dumpfile = @has_err_dumpfile = nil
          @iam_s_a = iam_s_a ; nil
        end
        attr_reader :cmd_s, :err_dumpfile_s,
          :has_err_dumpfile, :has_out_dumpfile,
          :is_opened, :out_dumpfile_s
        def any_opt_s
          @did_parse or parse
          @any_opt_s
        end
      private
        def parse
          @did_parse = true
          @scn = Multiline_Scanner_.new( @iam_s_a ) ; @iam_s_a = :_parsed_
          while ! @scn.eos?
            @scn.skip SOME_SPACE__
            word = scn_some_word
            @scn.skip SOME_SPACE__
            send :"#{ word }="
            @scn.skip SOME_SPACE__
          end
          post_parse ; nil
        end
        FILE_KEYWORD__ = /file\b/
        SOME_SPACE__ = /[ \t]+/
        TERM_NAME_RX__ = /[_a-z0-9]+/
        def serr=
          skip_some_file_keyword_and_space
          @has_err_dumpfile = true
          @err_dumpfile_s = scn_some_dumpfile_path ; nil
        end
        def file=
          @has_out_dumpfile = true
          @out_dumpfile_s = scn_some_dumpfile_path ; nil
        end
        def scn_some_dumpfile_path
          @scn.scan( EASY_WORD_RX__ ) or fail say_expecting_dumpfile_path
        end ; EASY_WORD_RX__ = /[^ ]+/
        def say_expecting_dumpfile_path
          say_expecting "expected dumpfile path"
        end
        def skip_some_file_keyword_and_space
          @scn.skip FILE_KEYWORD__ or fail say_expecting_file_keyword
          @scn.skip SOME_SPACE__ ; nil
        end
        def say_expecting_file_keyword
          say_expecting "the only thing that can follow 'serr' is 'file'"
        end
        def scn_some_word
          @scn.scan TERM_NAME_RX__ or fail say_expecting_word
        end
        def say_expecting_word
          say_expecting "expecting word"
        end
        def options=
          d = @scn.string.rindex END_CURLY__
          d or fail say_expecting_end_curly
          @any_opt_s = @scn.string[ @scn.pos .. d ]
          @scn.pos = d + 1 ; nil
        end ; END_CURLY__ = '}'.freeze
        def say_expecting_end_curly
          say_expecting "found no '}' anywhere before end of string"
        end

        def exitstatus=
          d = scn_some_digit
          @mock_wait_thread = Wait__.new do |w|
            w.value.exitstatus = d
          end ; nil
        end
        def scn_some_digit
          d_s = @scn.scan %r(\d+)
          d_s or fail say_expecting_digit
          d_s.to_i
        end
        def say_expecting_digit
          say_expecting "expected digit"
        end
        def say_expecting s
          _rest = Headless::CLI::FUN::Ellipsify[ @scn.rest ]
          _rest = "«#{ _rest }»"  # :+#guillemet
          "#{ s } at #{ _rest }"
        end

        def post_parse
          @any_opt_s ||= nil
          @mock_wait_thread ||= SUCCESS_WAIT__ ; nil
        end
        class Wait__
          def initialize
            @value = Value__.new
            yield self
            freeze
          end
          attr_reader :value
          Value__ = ::Struct.new :exitstatus
          def freeze
            @value.freeze
            super
          end
        end
        SUCCESS_WAIT__ = Wait__.new do |w|
          w.value.exitstatus = 0
        end

      public

        def open_cmd pn
          @is_opened = true ; @pn = pn
          @has_err_dumpfile && rd_err_dumpfile
          @has_out_dumpfile && rd_out_dumpfile
        end
      private
        def rd_out_dumpfile
          @o_a = rd_and_smartsplit_dumpfile @out_dumpfile_s ; nil
        end
        def rd_err_dumpfile
          @e_a = rd_and_smartsplit_dumpfile @err_dumpfile_s ; nil
        end
        def rd_and_smartsplit_dumpfile path_s
          @pn.join( path_s ).read.split LINE_BOUNDARY_RX__
        end
        LINE_BOUNDARY_RX__ = %r((?<=\n))
      public
        def get_four
          _mock_sout = gt_some_mock_sout
          _mock_serr = gt_some_mock_serr
          [ :_not_implemented_, _mock_sout, _mock_serr, @mock_wait_thread ]
        end
      private
        def gt_some_mock_serr
          if @has_err_dumpfile
            gt_scn_from_prototype_a @e_a
          else
            EMPTY_SCN__
          end
        end
        def gt_some_mock_sout
          if @has_out_dumpfile
            gt_scn_from_prototype_a @o_a
          else
            EMPTY_SCN__
          end
        end
        def gt_scn_from_prototype_a a
          a = a.dup
          Headless::Scn_.new do
            a.shift
          end
        end
        EMPTY_SCN__ = Headless::Scn_.new do end
      end

      class Multiline_Scanner_  # get rid of this by turning the entry
        # content into one big string early, at the first sign of trouble
        def initialize s_a
          @is_collapsed = @is_eos = false
          @idx = -1 ; @s_a = s_a ; @scn = nil ; @last = s_a.length - 1
          advance_to_any_next_nonempty_string
        end
      public
        def eos?
          if @is_collapsed
            @scn.eos?
          else
            @is_eos
          end
        end
        def scan rx
          send_inwards :scan, rx
        end
        def skip rx
          send_inwards :skip, rx
        end
      private
        def send_inwards i, x
          if @scn
            r = @scn.send i, x
            r && @scn.eos? && advance_to_any_next_nonempty_string
            r
          end
        end
      public
        def rest
          if @scn
            if @is_collapsed
              @scn.rest
            else
              y = [ @scn.rest ]
              @s_a[ @idx + 1 .. -1 ].each { |s| y << s }
              y * ''
            end
          end
        end
        def string
          @is_collapsed || omg_collapse
          @scn.string
        end
        def pos
          @is_collapsed or fail "sanity - .."
          @scn.pos
        end
        def pos= x
          @is_collapsed or fail "sanity .."
          @scn.pos = x
        end
      private
        def omg_collapse  # turn a scanner with lots of little strings
          # into a scanner with one big string only if you need to omg why
          @is_collapsed = true
          pos = calc_pos_when_collapsed
          @scn.string = @s_a.join ''
          @scn.pos = pos ; @idx = 0 ; @last = 0 ; @s_a = nil
        end
        def calc_pos_when_collapsed
          pos = if @idx.zero? then 0 else
            self._TEST_ME
            @s_a[ 0 .. @idx - 1 ].reduce 0 do |m, x|
              m + x.length
            end
          end
          pos + @scn.pos
        end
      private
        def advance_to_any_next_nonempty_string
          while true
            if @idx == @last
              @is_eos = true ; break
            end
            advance_to_next_string
            @scn.eos? or break
          end ; nil
        end
        def advance_to_next_string
          s = @s_a.fetch @idx += 1
          if @scn
            @scn.string = s
          else
            @scn = GitViz::Lib_::StringScanner[].new s
          end ; nil
        end
      end

      class Mock_System_Conduit_
        def popen3 * a
          block_given? and raise ::ArgumentError, "no, don't"
          cmd = Lookup_.new( @manifest_dirname_pn, @h, a ).execute
          cmd.get_four
        end
      end

      class Lookup_
        def initialize pn, h, a
          @h = h ; @manifest_dirname_pn = pn
          cmd = nrmlz_command a
          @normalized_cmd_s = cmd.normalized_cmd_s
          @any_opt_s = cmd.any_opt_s ;
        end
      private
        def nrmlz_command a
          env_h = ::Hash.try_convert( a.first ) and a.shift
          opt_h = ::Hash.try_convert( a.last ) and a.pop
          Incoming_Command_.new env_h, a, opt_h
        end
      public
        def execute
          @a = @h[ @normalized_cmd_s ]
          @a ? yes : no
        end
      private
        def no
          raise ::KeyError, "not in the manifest: «#{ @normalized_cmd_s }»"
        end
        def yes
          opt_s = @any_opt_s
          @a_ = @a.reduce [] do |m, x|
            opt_s == x.any_opt_s and m << x ; m
          end
          case @a_.length <=> 1
          when -1 ; when_zero
          when  0 ; when_one
          when  1 ; when_multiple
          end
        end
        def when_zero
          raise ::KeyError, say_when_zero
        end
        def say_when_zero
          "none of the #{ @a.length } command(s) have the options: #{
            }#{ @any_opt_s } (command was: #{ @normalized_cmd_s })"
        end
        def when_multiple
          raise ::KeyError, say_when_multiple
        end
        def say_when_multiple
          "multiple entries have the options: #{ @any_opt_s }. #{
            }(command was: #{ @normalized_cmd_s })"
        end
        def when_one
          cmd = @a_.fetch 0
          cmd.is_opened or cmd.open_cmd @manifest_dirname_pn
          cmd
        end
      end

      class Incoming_Command_
        def initialize env_h, cmd_s_a, opt_h
          env_h and raise ::NotImplementedError, "env too? #{ env_h }"
          @normalized_cmd_s = GitViz::Lib_::Shellwords[].shelljoin cmd_s_a
          opt_h and init_opt_h opt_h ; nil
        end
        attr_reader :normalized_cmd_s, :any_opt_s
      private
        def init_opt_h opt_h
          @any_opt_s = GitViz::Lib_::JSON[].generate opt_h ; nil
        end
      end
    end
  end
end
