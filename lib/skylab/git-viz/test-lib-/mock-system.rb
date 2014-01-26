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

      class IO_Lookup__  # #storypoint-45 #what-do-you-mean-by-IO
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
          @listeners = Listeners__.new
          @manifest_cls = Mock_System_Conduit_
          @cache_h = ::Hash.new do |h, cls|
            h[ cls ] = { }
          end
        end
        class Listeners__
          def initialize
            @h = { item_added: nil }
          end
          def add_listener * i_a, p
            last_h = last_i = nil
            a = i_a.reduce @h do |h, i|
              last_h = h ; last_i = i
              h.fetch i
            end
            a ||= last_h[ last_i ] = []
            a << p ; nil
          end
          def call * i_a, & p
            a = i_a.reduce @h do |h, i|
              h.fetch i
            end
            if a
              x = p.call
              a.each { |p_| p_[ x ] } ; nil
            end
          end
        end
        def on_item_added & p
          @listeners.add_listener :item_added, p ; nil
        end
        def resolve_some_cached_IO_instance_of_class_for_pn cls, pn
          retrieve_or_init do |o|
            o.IO_class = cls ;  o.IO_key = pn
            o.parse_all_ASAP = false
            o.when_retrieve_existing = IDENTITY_P__
            o.when_created_new = IDENTITY_P__
            o.handlers = nil
          end
        end
        def retrieve_or_init &p
          p[ Lookup_IO_Conduit__.new( lookup = Request_for_Lookup_IO__.new ) ]
          lookup.normalize
          x = lookup_any_cached_tuple lookup.IO_class, lookup.IO_key
          if x
            lookup.when_retrieve_existing[ x ]
          else
            parse_manifest lookup
          end
        end
        def parse_manifest lookup
          parse = Parse_Manifest__.new lookup
          ec = nil
          lookup.IO_key.open 'r' do |fh|
            ec = parse.parse_lines_in_peeking_scanner Counting_Peeker__.new fh
            ec and break
          end
          ec or add_to_cache( lookup, parse )
        end
        def add_to_cache lookup, parse
          cls = lookup.IO_class ; pn = lookup.IO_key
          io = lookup.IO_class.new( * parse.parsed_results_to_a, pn )
          @cache_h[ cls ][ pn ] = io
          @listeners.call :item_added do io end
          lookup.when_created_new[ io ]
        end
      public
        def lookup_any_cached_manifest_handle_for_pn pn
          lookup_any_cached_tuple @manifest_cls, pn
        end
        def lookup_any_cached_tuple cls, pn
          @cache_h[ cls ].fetch( pn ) {  }
        end
        def clear_cache_for_item_tuple cls, pn, yes_p, no_p
          if (( h = @cache_h.fetch( cls ) { } ))
            item = h.fetch( pn ) { }
            if item
              yes_p[ h.delete pn ]
            else
              no_p[ [ pn, cls, :pathname ] ]
            end
          else
            no_p[ [ cls, nil, :class ] ]
          end
        end
      end

      IDENTITY_P__ = -> x { x }

      class Lookup_IO_Conduit__
        def initialize container
          @container = container
        end
        [ :IO_class=, :IO_key=, :handlers=, :parse_all_ASAP=,
              :when_retrieve_existing=, :when_created_new= ].each do |i|
          define_method i do |x|
            @container.send i, x
          end
        end
      end

      class Request_for_Lookup_IO__
        attr_accessor :handlers, :IO_class, :IO_key, :parse_all_ASAP,
          :when_retrieve_existing, :when_created_new
        def normalize
          [ :IO_class, :IO_key,
              :when_retrieve_existing, :when_created_new ].each do |i|
            send i or raise ::ArgumentError, "missing required '#{ i }'"
          end
        end
      end

      class Parse_Manifest__

        def initialize lookup
          @cmd_a_h = {} ; @cmd_as_non_unique_key_s_a = []
          @entry_count = 0 ; @lookup = lookup
          @parse_now = lookup.parse_all_ASAP
        end

        def parsed_results_to_a
          [ @cmd_as_non_unique_key_s_a, @cmd_a_h, @entry_count ]
        end

        def parse_lines_in_peeking_scanner pscn
          @path = pscn.path ; @pscn = pscn
          parse_entry_prototype = Parse_Entry__.
            new @pscn, method( :receive_entry ), @lookup
          while true
            parse_entry = parse_entry_prototype.curry
            ec = parse_entry.parse_entry
            ec and break
            @pscn.peek or break
          end
          ec
        end
      private
        def receive_entry p
          _xx = p[ cmd = Stored_Command_.new ]
          if @parse_now
            ec = cmd.parse_with_context_and_handlers @pscn, @lookup.handlers
          end
          ec or accept_entry cmd
        end
        def accept_entry cmd
          @entry_count += 1
          ( @cmd_a_h.fetch cmd.cmd_s do |k|
            @cmd_as_non_unique_key_s_a << k
            @cmd_a_h[ k ] = []
          end ) << cmd
          PROCEDE_
        end
      end

      class Parse_Entry__

        def initialize pscn, accept_entry_p, handlers
          @accept_entry_p = accept_entry_p
          @handlers = handlers
          @pscn = pscn
        end
        def curry
          dup
        end
        def initialize_copy _
          @chopped_body_line_s_a = []
        end
        def parse_entry
          begin
            @line = @pscn.peek
            @line or break
            @line.chop!
            if current_line_is_skippable
              @pscn.gets
              redo
            end
            ec = validate_first_line and break
            @pscn.gets
            @start_line_no = @pscn.line_no
            ec = parse_entry_body
          end while false
          ec
        end
      private
        def current_line_is_skippable
          if BLANK_LINE_RX__ =~ @line
            blank_lines_are_skippable
          elsif SHELL_STYLE_COMMENT_LINE_RX__ =~ @line
            shell_style_comment_looking_lines_are_skippable
          end
        end

        BLANK_LINE_RX__ = /\A[[:blank:]]*\z/
        def blank_lines_are_skippable
          true
        end

        SHELL_STYLE_COMMENT_LINE_RX__ = /\A[[:blank:]]*#/
        def shell_style_comment_looking_lines_are_skippable
          true
        end

        def validate_first_line
          if VALID_FIRST_LINE_RX__ !~ @line
            _ex = Entry_Head_Can_Have_No_Indent.new @pscn
            @handlers.call :parse_error, :entry_head_with_indent, _ex,
              & method( :fail )
          end
        end
        VALID_FIRST_LINE_RX__ = /\A[^[:space:]]/

        def parse_entry_body
          @key_s, any_rest_of_line = @line.split RECORD_SEPARATOR__, -1
          any_rest_of_line and @chopped_body_line_s_a << any_rest_of_line
          ec = parse_any_sublines
          ec ||= validate
          ec || flush
        end
        RECORD_SEPARATOR__ = "\t".freeze

        def parse_any_sublines
          while true
            @line = @pscn.peek
            @line or break
            SPACE__ == @line.getbyte( 0 ) or break
            @pscn.gets
            @chopped_body_line_s_a << @line.chop!
          end
        end
        SPACE__ = ' '.getbyte 0

        def validate
          if @chopped_body_line_s_a.length.zero?
            emit_error_of_entry_with_no_body
          end
        end

        def emit_error_of_entry_with_no_body
          _ex = Entry_Must_Have_Body.new @pscn
          @handlers.call :parse_error, :entry_with_no_body, _ex
        end

        def flush
          @accept_entry_p[ -> cmd do
            cmd.cmd_s = @key_s.freeze
            cmd.body_s_a = @chopped_body_line_s_a
            cmd.line_no = @start_line_no
          end ]  # result of the outstream callback is our result.
        end
      end

      class Manifest_Parse_Error < ::RuntimeError
        def to_a
          [ message, self.class.get_normalized_class_basename,
              path, line, line_no, column ]
        end
        def self.get_normalized_class_basename
          s = name
          s[ (s.rindex ':') + 1 .. -1 ].downcase.intern
        end
      end

      class First_Pass_Manifest_Parse_Error < Manifest_Parse_Error

        def initialize pscn, msg=self.class::MESSAGE_S__, column=1
          @column = column
          @line = pscn.peek ; @line_no = pscn.line_no
          @path = pscn.path
          super msg
        end
        attr_reader :column, :line, :line_no, :path
          # indexes are unit- not zero-based
      end

      class Entry_Head_Can_Have_No_Indent < First_Pass_Manifest_Parse_Error
        MESSAGE_S__ = 'entry head line must have no leading space'.freeze
      end

      class Entry_Must_Have_Body < First_Pass_Manifest_Parse_Error
        MESSAGE_S__ = 'entry must have body (iambic name-values pairs)'.freeze
      end

      class Counting_Peeker__  # give a filehandle simple peek and linecount
        def initialize x
          @instream = x ; @is_buffered = false
          @line_no = 0  # unit-indexed not zero-indexed
        end
        attr_reader :line_no
        def path
          @instream.path
        end
        def gets
          if @is_buffered
            @is_buffered = false
            x = @buffer_value ; @buffer_value = nil ; x
          else
            s = @instream.gets and @line_no += 1 ; s
          end
        end
        def peek
          if ! @is_buffered
            @is_buffered = true
            @buffer_value = @instream.gets and @line_no += 1
          end
          @buffer_value
        end
      end

      class Manifest_IO___  # (abstract base class for at least 2 children)
        def initialize cmd_key_s_a, cmd_a_h, entry_count, pn
          @cmd_a_h = cmd_a_h ; @cmd_as_non_unique_key_s_a = cmd_key_s_a
          @entry_count = entry_count ; @manifest_dirname_pn = pn.dirname
          @manifest_pathname = pn
        end
        attr_reader :manifest_pathname  # only used by server plugins omz
        def manifest_summary
          "#{ @entry_count } entries (#{ unique_commands_count }#{
            } unique commands)"
        end
        attr_reader :entry_count
        def unique_commands_count
          @cmd_as_non_unique_key_s_a.length
        end
      end

      class Stored_Command_
        def initialize
          @did_parse = false ; @did_parse_opt_s = false
          @exitstatus_is_query = false ; @freetag_a = nil
          @has_out_dumpfile = @has_err_dumpfile = nil
          @mock_wait_thread = nil
        end
        attr_writer :body_s_a, :cmd_s, :line_no
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
          require 'strscan'  # oh my god so bad. in rbx only, unless we require
          # *anything* else beforehand, an attempt to require 'json' at this
          # point (but not before) raises a load error! #todo:wtf
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
          @did_parse or @parse_result = parse
          @parse_result
        end
        def parse_with_context_and_handlers pscn, handlers
          @parse_ctxt = pscn ; @handlers = handlers
          @parse_result = parse
          @parse_ctxt = @handlers = nil
          @parse_result
        end
      private
        def parse
          @did_parse = true
          @scn = Multiline_Scanner_.new( @body_s_a ) ; @body_s_a = :_parsed_
          while true
            @scn.skip SOME_SPACE__
            @scn.eos? and break
            ec = if (( @word_s = scn_any_word ))
              scn_rest_of_word
            elsif (( @freetag = scn_any_freetag ))
              process_freetag
            else
              expecting_word_or_freetag
            end
            ec and break
          end
          ec || post_parse
        end
        def scn_rest_of_word
          @scn.skip SOME_SPACE__
          send self.class.map_word_to_method_name @word_s
        end
        def self.map_word_to_method_name s
          TERM_H__[ s.intern ]
        end
        TERM_I_A__ = [ :exitstatus, :file, :options, :serr ].freeze
        TERM_H__ = -> do
          h = ::Hash[ TERM_I_A__.map { |i| [ i, "#{ i }=".intern ] } ]
          h.default = :unexpected_term
          h
        end.call
        def unexpected_term
          _ex = Unexpected_Term_Parse_Error.
            new @word_s, TERM_I_A__, @parse_ctxt.path, @line_no
          @handlers.call :parse_error, :unexpected_term, _ex
        end
      end
      class Entry_Parse_Error < Manifest_Parse_Error
        def initialize msg, path, line, line_no, col=1
          @column = col ; @line = line
          @line_no = line_no ; @path = path
          super msg
        end
        attr_reader :column, :line, :line_no, :path
          # indexes are unit- not zero-based
      end
      class Unexpected_Term_Parse_Error < Entry_Parse_Error
        def initialize s, a, path, line_no
          _s = GitViz::Lib_::Oxford[ ', ', '[none]', ' or ', a ]
          super "unexpected term. did you mean #{ _s }?",
            path, "[..]#{ s }", line_no, COLUMN__
        end
        ELLIPSIS__ = '[..]'.freeze
        COLUMN__ = ELLIPSIS__.length + 1
      end
      class Stored_Command_  # (re-open)
        def expecting_word_or_freetag
          self._DO_ME
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
            new( @manifest_dirname_pn, @cmd_a_h, a ).lookup_for_playback
          cmd.get_four
        end
      end

      class Lookup_for_playback__
        def initialize pn, h, a
          @cmd_a_h = h ; @manifest_dirname_pn = pn
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
          @a = @cmd_a_h[ @normalized_cmd_s ]
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
      PROCEDE_ = nil
    end
  end
end
