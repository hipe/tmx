module Skylab::GitViz

  module Test_Lib_

    module Mock_System  # read [#023] the mock system narrative #introduction

      def self.[] user_mod
        user_mod.module_exec do
          extend Module_Methods__
          include Instance_Methods__ ; nil
        end
      end

      module Instance_Methods__
      private
        def mock_system_conduit
          IO_Lookup__.new( self ).lookup_system_conduit
        end
      public
        def resolve_any_manifest_handle
          IO_Lookup__.new( self ).lookup_manifest_handle
        end
        def get_system_command_manifest_pn
          fixtures_module.dir_pathname.join 'system-commands.manifest'
        end
        def fixtures_module
          self.class.fixtures_mod
        end
        def resolve_any_memoized_IO_cache lookup
          fixtures_module.module_exec do
            @fixture_IO_cache ||= lookup.build_IO_cache
          end
        end
      end

      module Module_Methods__
        def fixtures_mod
          send( :nearest_test_node )::Fixtures  # covered
        end
      end

      class IO_Lookup__
        def initialize client
          @client = client
        end
        def lookup_system_conduit
          @IO_class = Mock_System_Conduit_
          lookup
        end
        def lookup_manifest_handle
          @IO_class = Mock_System::Manifest::Handle
          lookup
        end
      private
        def lookup
          @pn = @client.get_system_command_manifest_pn
          rslv_some_cached_IO_for_pathname
        end
        def rslv_some_cached_IO_for_pathname
          x = @client.resolve_any_memoized_IO_cache self
          x ||= @client.build_and_memoize_and_get_IO_cache
          x.resolve_some_cached_IO_instance_of_class_for_pn @IO_class, @pn
        end
      public
        def build_IO_cache
          Mock_Command_IO_Cache_.new
        end
      end

      class Mock_Command_IO_Cache_
        def initialize
          @manifest_cls = Mock_System_Conduit_
          @cache_h = ::Hash.new do |h, cls|
            h[ cls ] = ::Hash.new do |h_, pn|
              h_[ pn ] = cls.new pn
            end
          end
        end
        def lookup_any_cached_manifest_handle_for_pn pn
          @cache_h[ @manifest_cls ].fetch( pn ) {  }
        end
        def resolve_some_cached_IO_instance_of_class_for_pn cls, pn
          @cache_h[ cls ][ pn ]
        end
      end

      class Manifest_IO___  # (abstract base class for at least 2 children)
        def initialize pn
          @cmd_as_non_unique_key_s_a = []
          @h = {} ; pn.open 'r' do |fh|
            Parse_Manifest_.new( fh, method( :accpt_line ) ).execute
          end
          @manifest_dirname_pn = pn.dirname ; nil
        end
      private
        def accpt_line cmd_s, iam_s_a
          cmd = Stored_Command_.new cmd_s.freeze, iam_s_a
          ( @h.fetch cmd.cmd_s do |k|
            @cmd_as_non_unique_key_s_a << k
            @h[ k ] = []
          end ) << cmd ; nil
        end
      end

      class Parse_Manifest_
        def initialize fh, p
          @accept_line_p = p ; @fh = Peeker__.new( fh )
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

      class Peeker__
        def initialize x
          @instream = x ; @is_buffered = false
        end
        def gets
          if @is_buffered
            @is_buffered = false
            x = @buffer_value ; @buffer_value = nil ; x
          else
            @instream.gets
          end
        end
        def peek
          if ! @is_buffered
            @is_buffered = true
            @buffer_value = @instream.gets
          end
          @buffer_value
        end
      end

      class Stored_Command_
        def initialize cmd_s, iam_s_a
          @cmd_s = cmd_s ; @did_parse = false
          @did_parse_opt_s = false
          @exitstatus_is_query = false
          @freetag_a = nil
          @has_out_dumpfile = @has_err_dumpfile = nil
          @iam_s_a = iam_s_a ; @mock_wait_thread = nil
        end
        attr_reader :cmd_s, :err_dumpfile_s,
          :exitstatus_is_query,
          :has_err_dumpfile, :has_out_dumpfile,
          :is_opened, :out_dumpfile_s
        def any_chdir_s
          h = any_opt_h
          h && h[ :chdir ]
        end
        def any_opt_h
          @did_parse_opt_s or parse_opt_s
          @any_opt_h
        end
      private
        def parse_opt_s
          @did_parse_opt_s = true
          h = GitViz::Lib_::JSON[].parse @any_opt_s, symbolize_names: true
          @any_opt_h = h.freeze ; nil
        end
      public
        def any_opt_s
          parse_everything_as_necessary
          @any_opt_s
        end
        def result_code_mixed_string
          if @exitstatus_is_query then EC_QUERY_S__ else
            d = @mock_wait_thread.value.exitstatus
            d.nonzero? and d.to_s
          end
        end
        EC_QUERY_S__ = '(ec?)'.freeze  # short, normalized, still readable
        def parse_everything_as_necessary
          @did_parse or parse ; nil
        end
      private
        def parse
          @did_parse = true
          @scn = Multiline_Scanner_.new( @iam_s_a ) ; @iam_s_a = :_parsed_
          while true
            @scn.skip SOME_SPACE__
            @scn.eos? and break
            if (( @word_s = scn_any_word ))
              scn_rest_of_word
            elsif (( @freetag = scn_any_freetag ))
              process_freetag
            else
              fail say_expecting_word_or_freetag
            end
          end
          post_parse ; nil
        end
        def scn_rest_of_word
          @scn.skip SOME_SPACE__
          send :"#{ @word_s }="
        end
        def say_expecting_word_or_freetag
          say_expecting "expecting word or #freetag"
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
        def scn_any_word
          @scn.scan TERM_NAME_RX__
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
          d_s = @scn.scan %r(\d+)
          if d_s
            accept_exitstatus_digit d_s.to_i
          elsif @scn.skip MIXED_QUESTION_MARK_RX__
            exitstatus_query_notify
          else
            fail say_expecting_mixed_exitstatus
          end
        end
        MIXED_QUESTION_MARK_RX__ = /[^ ?)]*\?+\)?(?![^ ])/
        def accept_exitstatus_digit d
          @mock_wait_thread = Wait__.new do |w|
            w.value.exitstatus = d
          end ; nil
        end
        def say_expecting_mixed_exitstatus
          say_expecting "expected digit or e.g \"(foo?)\" or just \"?\""
        end
        def say_expecting s
          _rest = FUN_::Ellipsify[ @scn.rest ]
          _rest = "«#{ _rest }»"  # :+#guillemet
          "#{ s } at #{ _rest }"
        end
        def exitstatus_query_notify
          @exitstatus_is_query = true
          @mock_wait_thread = :_query_ ; nil
        end

        # ~ freetags
      public
        attr_reader :freetag_a
        def marshalled_freetags
          @freetag_a and @freetag_a.first.class.marshall @freetag_a
        end
      private
        def scn_any_freetag
          @freetag_identifier = @scn.scan FREETAG_IDENTIFIER_RX__
          @freetag_identifier && scn_rest_of_freetag
        end
        FREETAG_IDENTIFIER_RX__ = /#[a-zA-Z][-a-zA-Z0-9]+(?=$|[[:space:]]|:)/
        FREETAG_NECK_RX__ = /:/
        FREETAG_BODY_RX__ = /[-_a-zA-Z0-9]+(?=$|[[:space:]])/
        def scn_rest_of_freetag
          @freetag_body = if @scn.skip FREETAG_NECK_RX__
            scn_some_freetag_body
          end
          bld_freetag
        end
        def scn_some_freetag_body
          @scn.scan FREETAG_BODY_RX__ or fail say_expecting_freetag_body
        end
        def say_expecting_freetag_body
          say_expecting "expecting valid freetag body value"
        end
        def bld_freetag
          Mock_System::Manifest::FreeTag.new @freetag_identifier, @freetag_body
        end
        def process_freetag
          @freetag_body = @freetag_identifier = nil
          @freetag_a ||= [] << @freetag ; @freetag = nil
        end
        # (end freetag)

        def post_parse
          @any_opt_s ||= nil
          @freetag_a && @freetag_a.freeze
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
          [ :_env_not_implemented_, _mock_sout, _mock_serr, @mock_wait_thread ]
        end
      private
        def gt_some_mock_serr
          if @has_err_dumpfile
            gt_scn_from_prototype_a @e_a
          else
            FUN_::EMPTY_SCN
          end
        end
        def gt_some_mock_sout
          if @has_out_dumpfile
            gt_scn_from_prototype_a @o_a
          else
            FUN_::EMPTY_SCN
          end
        end
        def gt_scn_from_prototype_a a
          a = a.dup
          FUN_::Scn[].new do
            a.shift
          end
        end
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

      class Mock_System_Conduit_ < Manifest_IO___
        def popen3 * a
          block_given? and raise ::ArgumentError, "no, don't"
          cmd = Lookup_for_playback__.
            new( @manifest_dirname_pn, @h, a ).lookup_for_playback
          cmd.get_four
        end
      end

      class Lookup_for_playback__
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
        def lookup_for_playback
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

      module FUN_

        Ellipsify = -> x do
          if GitViz.const_defined?( :Lib_, false )
            GitViz::Lib_::Headless[]::CLI::FUN::Ellipsify[ x ]
          elsif 10 < x.length
            "#{ x[ 0, 6 ] }[..]"
          else
            x
          end
        end

        class Scn__ < ::Proc
          alias_method :gets, :call
        end
        Scn = -> do
          Scn__
        end
        EMPTY_SCN = Scn__.new do end
      end

      Mock_System = self
    end
  end
end
