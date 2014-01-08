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
            line = fh.gets or fail "empty command manifest file: #{ fh.path }"
            begin
              parse_line line
            end while (( line = fh.gets ))
          end
          @manifest_dirname_pn = pn.dirname ; nil
        end
      private
        def parse_line line
          line.chop!
          accpt_line( * line.split( RECORD_SEPARATOR__, -1 ) )
        end
        RECORD_SEPARATOR__ = "\t".freeze
        def accpt_line cmd_s, op_s
          cmd = Stored_Command_.new cmd_s.freeze, op_s
          ( @h.fetch cmd.cmd_s do |k|
            @h[ k ] = []
          end ) << cmd ; nil
        end
      end

      class Stored_Command_
        def initialize cmd_s, op_s
          @cmd_s = cmd_s ; @did_parse = false ; @op_s = op_s ; nil
        end
        attr_reader :cmd_s, :is_opened
        def any_opt_s
          @did_parse or parse
          @any_opt_s
        end
      private
        def parse
          @did_parse = true ; ( @scn = SCANNER__ ).string = @op_s
          while ! @scn.eos?
            word = @scn.scan TERM_NAME_RX__
            word or fail "expected word: #{ @scn.rest }"
            @scn.skip SOME_SPACE__
            send :"#{ word }="
            @scn.skip SOME_SPACE__
          end
          post_parse ; nil
        end
        SCANNER__ = GitViz::Services::StringScanner[].new ''
        TERM_NAME_RX__ = /[_a-z0-9]+/
        SOME_SPACE__ = /[ \t]+/
        def file=
          @file_s = @scn.scan EASY_WORD_RX__
          @file_s or fail "expecting word" ; nil
        end
        public ; attr_reader :file_s ; private
        EASY_WORD_RX__ = /[^ ]+/
        def options=
          d = @scn.string.rindex END_CURLY__
          @any_opt_s = @scn.string[ @scn.pos .. d ]
          @scn.pos = d + 1 ; nil
        end
        END_CURLY__ = '}'.freeze

        def exitstatus=
          d_s = @scn.scan %r(\d+)
          d_s or fail "expected digit: #{ @scn.rest }"
          @mock_wait_thread = Wait__.new do |w|
            w.value.exitstatus = d_s.to_t
          end ; nil
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
          @is_opened = true
          _s = pn.join( @file_s ).read
          @o_a = _s.split( %r((?<=\n)) ) ; nil
        end
        def get_four
          o_a = @o_a.dup
          mock_sout = Headless::Scn_.new do
            o_a.shift
          end
          mock_serr = EMPTY_SCN__
          [ :_not_implemented_, mock_sout, mock_serr, @mock_wait_thread ]
        end

        EMPTY_SCN__ = Headless::Scn_.new do end
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
          raise ::KeyError, "not in the manifest: #{ @normalized_cmd_s }"
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
          @normalized_cmd_s = GitViz::Services::Shellwords[].shelljoin cmd_s_a
          opt_h and init_opt_h opt_h ; nil
        end
        attr_reader :normalized_cmd_s, :any_opt_s
      private
        def init_opt_h opt_h
          @any_opt_s = GitViz::Services::JSON[].generate opt_h ; nil
        end
      end
    end
  end
end
