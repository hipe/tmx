module Skylab::GitViz

  module Test_Lib_

    module Mock_System  # read [#023] the mock system narrative #introduction

      def self.[] user_mod
        user_mod.module_exec do
          extend Module_Methods__
          include Instance_Methods__ ; nil
        end
      end

      In_module = -> mod, relpath=DEFAULT_RELPATH_ do
        mod.module_exec do
          ( @mock_system_cache ||= Mock_Command_IO_Cache_.new ).
            resolve_some_cached_IO_instance_of_class_for_pn(
              Mock_System_Conduit_, dir_pathname.join( relpath ) )
        end
      end

      DEFAULT_RELPATH_ = 'system-commands.manifest'.freeze

      module Instance_Methods__
      private
        def mock_system_conduit
          @mock_system_conduit ||=
            In_module[ fixtures_module, system_commands_manifest_relpath ]
        end
        def fixtures_module
          self.class.fixtures_mod
        end
        def system_commands_manifest_relpath
          DEFAULT_RELPATH_
        end
      end

      module Module_Methods__
        def fixtures_mod
          self.nearest_test_node::Fixtures  # covered
        end
      end

      # #storypoint-45 #what-do-you-mean-by-IO

      class Mock_Command_IO_Cache_
        def initialize
          @cache_h = ::Hash.new do |h, cls|
            h[ cls ] = { }
          end
          @callbacks = Callback_Tree__.new
          @manifest_cls = Mock_System_Conduit_
        end
        class Callback_Tree__ < Callback_Tree_
          def initialize
            super item_added: :listeners
          end
        end
        def on_item_added & p
          @callbacks.add_listener :item_added, p ; nil
        end
        def resolve_some_cached_IO_instance_of_class_for_pn cls, pn
          retrieve_or_init do |o|
            o.IO_class = cls ;  o.IO_key = pn
            o.parse_all_ASAP = false
            o.when_retrieve_existing = IDENTITY_P__
            o.when_created_new = IDENTITY_P__
            o.callbacks = nil
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
            ec = parse.parse_lines_in_peeking_stream Counting_Peeker__.new fh
            ec and break
          end
          ec or add_to_cache( lookup, parse )
        end
        def add_to_cache lookup, parse
          cls = lookup.IO_class ; pn = lookup.IO_key
          io = lookup.IO_class.new( * parse.parsed_results_to_a, pn )
          @cache_h[ cls ][ pn ] = io
          @callbacks.call_listeners :item_added do io end
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
        [ :IO_class=, :IO_key=, :callbacks=, :parse_all_ASAP=,
              :when_retrieve_existing=, :when_created_new= ].each do |i|
          define_method i do |x|
            @container.send i, x
          end
        end
      end

      class Request_for_Lookup_IO__
        attr_accessor :callbacks, :IO_class, :IO_key, :parse_all_ASAP,
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

        def parse_lines_in_peeking_stream pscn
          @path = pscn.path ; @pscn = pscn
          parse_entry_prototype = Parse_Entry__.
            new @pscn, @lookup, method( :receive_entry )
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
          ec = p[ cmd = Stored_Command_.new ]  # #jump-1
          if ! ec && @parse_now
            ec = cmd.parse_with_context_and_handlers @pscn, @lookup.callbacks
          end
          ec or accept_entry cmd
        end
        def accept_entry cmd
          @entry_count += 1
          ( @cmd_a_h.fetch cmd.cmd_s do |k|
            @cmd_as_non_unique_key_s_a << k
            @cmd_a_h[ k ] = []
          end ) << cmd
          CONTINUE_
        end
      end

      class Parse_Entry__

        def initialize pscn, lookup, accept_entry_p
          @accept_entry_p = accept_entry_p
          @callbacks = lookup.callbacks
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
            @callbacks.call_handler :error, :parse, :entry_head_with_indent, _ex
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
          @callbacks.call_handler :error, :parse, :entry_with_no_body, _ex
        end

        def flush
          @accept_entry_p[ -> cmd do  # :#jump-1
            cmd.cmd_s = @key_s.freeze
            cmd.body_s_a = @chopped_body_line_s_a
            cmd.line_no = @start_line_no
            CONTINUE_
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

      class Stored_Command_
        def initialize
          @any_opt_s = nil ; @did_parse = false
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
          h = any_opt_h and h[ :chdir ]
        end
        def any_opt_h
          @did_parse or parse
          @any_opt_h
        end
        def any_opt_s
          @did_parse or parse
          @any_opt_s
        end
        def result_code_mixed_string
          if @exitstatus_is_query then EC_QUERY_S__ else
            d = @mock_wait_thread.value.exitstatus
            d.nonzero? and d.to_s
          end
        end
        EC_QUERY_S__ = '(ec?)'.freeze  # short, normalized, still readable
        def resolve_some_parse_result
          @did_parse or @parse_result = parse
          @parse_result
        end
        def parse_with_context_and_handlers pscn, cbx
          @callbacks = cbx ; @parse_ctxt = pscn
          @parse_result = parse
          @parse_ctxt = @callbacks = nil
          @parse_result
        end
      private
        def parse
          @did_parse = true
          @scn = Multiline_Scanner_.new( @body_s_a ) ; @body_s_a = :_parsed_
          while true
            @scn.skip SOME_SPACE__
            @scn.eos? and break
            ec = if scn_any_word
              scn_rest_of_word
            elsif scn_any_freetag
              scn_rest_of_freetag
            else
              expecting_word_or_freetag
            end
            ec and break
            ec = parse_any_opt_s
          end
          ec || post_parse
        end
        def scn_any_word
          @word_s = @scn.scan TERM_NAME_RX__
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
          @callbacks.call_handler :error, :parse, :unexpected_term, _ex
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
          _s = GitViz_.lib_.oxford_or a
          super "unexpected term. did you mean #{ _s }?",
            path, "#{ ELLIPSIS__ }#{ s }", line_no, COLUMN__
        end
        ELLIPSIS__ = '[..]'.freeze
        COLUMN__ = ELLIPSIS__.length + 1
      end
      class Stored_Command_  # (re-open)
        def expecting_word_or_freetag
          respond_with_general_parse_error say_expecting_word_or_freetag
        end
        def say_expecting_word_or_freetag
          "expecting word or #freetag"
        end
        FILE_KEYWORD__ = /file\b/
        SOME_SPACE__ = /[ \t]+/
        TERM_NAME_RX__ = /[_a-z0-9]+/
        def serr=
          ec = skip_some_file_keyword_and_space
          ec || scn_rest_of_serr_file
        end
        def scn_rest_of_serr_file
          @has_err_dumpfile = true
          scn_some_dumpfile_path -> s do
            @err_dumpfile_s = s ; CONTINUE_
          end, method( :respond_with_general_parse_error )
        end
        def file=
          @has_out_dumpfile = true
          scn_some_dumpfile_path -> s do
            @out_dumpfile_s = s ; CONTINUE_
          end, method( :respond_with_general_parse_error )
        end
        def scn_some_dumpfile_path yes_p, no_p
          s = @scn.scan EASY_WORD_RX__
          s ? yes_p[ s ] : no_p[ say_expecting_dumpfile_path ]
        end ; EASY_WORD_RX__ = /[^ ]+/
        def say_expecting_dumpfile_path
          "expected dumpfile path"
        end
        def skip_some_file_keyword_and_space
          d = @scn.skip FILE_KEYWORD__
          d and @scn.skip SOME_SPACE__
          ! d and respond_with_general_parse_error( say_expecting_file_keyword )
        end
        def say_expecting_file_keyword
          "the only thing that can follow 'serr' is 'file'"
        end
        def options=
          d = @scn.string.rindex END_CURLY__
          d ? scn_rest_of_JSON_object( d ) :
            respond_with_general_parse_error( say_expecting_end_curly )
        end ; END_CURLY__ = '}'.freeze
        def scn_rest_of_JSON_object d
          @any_opt_s = @scn.string[ @scn.pos .. d ]
          @scn.pos = d + 1
          CONTINUE_
        end
        def say_expecting_end_curly
          "found no '}' anywhere before end of string"
        end

        def exitstatus=
          d_s = @scn.scan %r(\d+)
          if d_s
            accept_exitstatus_digit d_s.to_i
          elsif @scn.skip MIXED_QUESTION_MARK_RX__
            exitstatus_query_notify
          else
            respond_with_general_parse_error say_expecting_mixed_exitstatus
          end
        end
        MIXED_QUESTION_MARK_RX__ = /[^ ?)]*\?+\)?(?![^ ])/
        def accept_exitstatus_digit d
          @mock_wait_thread = Wait__.new do |w|
            w.value.exitstatus = d
          end ; CONTINUE_
        end
        def say_expecting_mixed_exitstatus
          "expected digit or e.g \"(foo?)\" or just \"?\""
        end
        def exitstatus_query_notify
          @exitstatus_is_query = true
          @mock_wait_thread = :_query_ ; CONTINUE_
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
        end
        FREETAG_IDENTIFIER_RX__ = /#[a-zA-Z][-a-zA-Z0-9]+(?=$|[[:space:]]|:)/
        FREETAG_NECK_RX__ = /:/
        FREETAG_BODY_RX__ = /[-_a-zA-Z0-9]+(?=$|[[:space:]])/
        def scn_rest_of_freetag
          if @scn.skip FREETAG_NECK_RX__
            ec = scn_freetag_body
          else
            @freetag_body = nil
          end
          ec || prcss_freetag_parts
        end
        def scn_freetag_body
          if (( s = @scn.scan FREETAG_BODY_RX__ ))
            @freetag_body = s ; CONTINUE_
          else
            respond_with_general_parse_error say_expecting_freetag_body
          end
        end
        def say_expecting_freetag_body
          "expecting valid freetag body value"
        end
        def prcss_freetag_parts
          ft = Mock_System::Manifest_Entry_::FreeTag.
            new @freetag_identifier, @freetag_body
          @freetag_body = @freetag_identifier = nil
          ( @freetag_a ||= [] ) << ft ; CONTINUE_
        end
        # (end freetag)

        def parse_any_opt_s
          if @any_opt_s
            prs_opt_s
          else
            @any_opt_h = nil ; CONTINUE_
          end
        end
        def prs_opt_s
          h = GitViz_.lib_.JSON.parse @any_opt_s, symbolize_names: true
          @any_opt_h = h.freeze ; CONTINUE_
        rescue GitViz_.lib_.JSON::ParserError => e
          respond_with_general_parse_error e.message
        end
        def respond_with_general_parse_error msg_s
          _line = @scn.string
          _col = @scn.pos + 1
          _ex = Entry_Parse_Error.new msg_s, @parse_ctxt.path, _line,
            @line_no, _col
          @callbacks.call_handler :error, :parse, :entry, _ex
        end
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
            Callback_::Scn.the_empty_stream
          end
        end
        def gt_some_mock_sout
          if @has_out_dumpfile
            gt_scn_from_prototype_a @o_a
          else
            Scn_.the_empty_stream
          end
        end
        def gt_scn_from_prototype_a a
          a = a.dup
          Scn_.new do
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
            @scn = GitViz_.lib_.string_scanner.new s
          end ; nil
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
          @normalized_cmd_s = GitViz_.lib_.shellwords.shelljoin cmd_s_a
          opt_h and init_opt_h opt_h ; nil
        end
        attr_reader :normalized_cmd_s, :any_opt_s
      private
        def init_opt_h opt_h
          @any_opt_s = GitViz_.lib_.JSON.generate opt_h ; nil
        end
      end

      class Manifest_  # (abstract base class for at least 2 children)
        def initialize cmd_key_s_a, cmd_a_h, entry_count, pn
          @cmd_a_h = cmd_a_h ; @cmd_as_non_unique_key_s_a = cmd_key_s_a
          @entry_count = entry_count ; @manifest_dirname_pn = pn.dirname
          @manifest_pathname = pn
        end
        Autoloader_[ self ]
      end

      class Mock_System_Conduit_ < Manifest_
        def popen3 * a
          block_given? and raise ::ArgumentError, "no, don't"
          cmd = Lookup_for_playback__.
            new( @manifest_dirname_pn, @cmd_a_h, a ).lookup_for_playback
          cmd.get_four
        end
      end

      module Socket_Agent_Constants_  # first utilisant of [#hl-155] name conv.
        # (e->3 g->6)
        EARLY_EXIT_ = 33 ; GENERAL_ERROR_ = 63
        IO_THREADS_COUNT__ = 1
        SILENT_ = nil
      end

      Mock_System = self

    end
  end
end
