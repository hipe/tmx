module Skylab::Git::CLI::Actions::Stash_Untracked

  # read [#010] #storypoint-1 "introduction..", #storypoint-2 "local idioms"

  Autoloader = ::Skylab::Autoloader  # #storypoint-3 "these constant ass.."
  Git = ::Skylab::Git
  MetaHell = ::Skylab::MetaHell
  Basic = Git::Services::Basic
  Headless = Git::Services::Headless

  module Sub_client__  # #storypoint-4 "the way sub-clients are used in t.."

    def self.[] mod, * x_a  # re-entrant
      mod.send :include, Sub_client_universal_IMs__
      x_a.length.zero? and raise ::ArgumentError, "cherry-pick only."
      apply_iambic_on_client x_a, mod ; nil
    end

    As_basic_set = -> x_a do
      module_exec x_a, & Basic::Set.to_proc
    end

    As_basic_set_via_params_const = -> x_a do
      x_a.unshift :with_members, -> do
        self.class::PARAMS
      end
      module_exec x_a, & Basic::Set.to_proc
    end

    Color_inquisitor = -> _ do
    private
      def is_in_color
        resolve_service( :color_inquisition ).invoke nil, nil
      end
    end

    Emit_payload_line_to_listener = -> _ do
    private
      def emit_payload_line s
        @listener_p[ s ]
      end
    end

    Emitters = -> _ do  # #storypoint-5 the sub-client implementation of..
      include Sub_client_emitters_IMs__
    end

    File_utils = -> x_a do
      module_exec x_a, & FU_Bundle_and_IMs__.to_proc
    end

    Funcy = -> _ do
      MetaHell::Funcy[ self ] ; nil
    end

    Popener3 = -> x_a do
    private
      def popen3 *a, &p
        _svc = @client.resolve_service :popen3
        _svc.invoke a, p
      end
    end

    Say = -> _ do
      # ~ :storypoint-6 - the default way that s.c interface with the exag.
    private
      def say & p
        _exag = resolve_service( :some_expression_agent ).invoke nil, nil
        _exag.calculate( & p )
      end
    end

    Service_terminal = -> x_a do
      module_exec x_a, & Headless::Service_Terminal.to_proc
    end

    Shellesc = -> _ do
    private
      def shellesc x
        Git::Services::Shellwords.shellescape x
      end
    end

    Verb_lemma_hack = -> _ do
      def self.verb_lemma_s
        Verb_lemma_hack_[ self ]
      end ; nil
    end

    MetaHell::Bundle::Multiset[ self ]
  end

  Verb_lemma_hack_ = -> mod do
    s = mod.name ; base_s = s[ s.rindex( COLON__ ) + 1 .. -1 ]
    base_s.downcase
  end
  COLON__ = ':'.freeze

  module Sub_client_universal_IMs__
  private
    def client_notify x
      @client = x
    end
    def resolve_service i
      @client.resolve_service i
    end
  end

  module Sub_client_emitters_IMs__  # :#storypoint-5 the sub-client imple..
  private

    def emit_payload_line s
      @client.emit_payload_line s
    end

    def emit_inner_error_string s
      @client.emit_inner_error_string s
    end

    def emit_error_line s
      @client.emit_error_line s
    end

    def emit_inner_info_string s
      @client.emit_inner_info_string s
    end

    def emit_info_line s
      @client.emit_info_line s
    end
  end

  class CLI

    Sub_client__[ self,
      :service_terminal, :service_module, -> { Services__ } ]

    Headless::CLI::Client[ self, :client_services,
                           :three_streams_notify, :instance_methods ]

    def initialize i, o, e
      @param_h = { }
      three_streams_notify i, o, e
      super
    end

  private
    def pen_class
      Expression_Agent__
    end
    class Expression_Agent__ < Headless::CLI::Pen::Minimal
      def escape_path x
        _s = x.to_s
        Headless::CLI::PathTools::FUN.pretty_path[ _s ]
      end
    end
  public

    client_services_class
    class Client_Services
      delegating :with_suffix, :_notify, %i( emit_info_line
        emit_error_line emit_payload_line
        is_in_color popen3 some_expression_agent )
    end
    # top-client #storypoint-5 is just straightforward pass-in here
    def emit_error_line_notify s
      emit_error_line s
    end
    def emit_info_line_notify s
      emit_info_line s
    end
    def emit_payload_line_notify s
      emit_payload_line s
    end
    # (#storypoint-6 again - buckstopper)
    def some_expression_agent_notify
      @IO_adapter.pen
    end

    define_method :popen3_notify, & Git::Services::Open3.method( :popen3 )
    # gets stubed by tests, hence at top # :#storypoint-7: this?

  private

    # ~ CLI action support - options

    def stashes_option o
      @param_h[ :stashes_path ] = nil
      o.on '-s', '--stashes <path>',
          "use <path> as stashes path and pwd as hub dir" do |s|
        @param_h[ :stashes_path ] = s
      end
    end

    def dry_run_option o
      @param_h[ :dry_run ] = false
      o.on '-n', '--dry-run', "Dry run." do
        @param_h[ :dry_run ] = true
      end
      nil
    end

    def verbose_option o
      @param_h[:be_verbose] = false
      o.on '-v', '--verbose', 'verbose output' do
        @param_h[:be_verbose] = true
      end
      nil
    end

    def help_option o
      o.on '-h', '--help', 'this screen' do
        enqueue_help
      end
      nil
    end

    # ~ support for interfacing with API

    def invoke_API action_locator_x, par_h
      cls = API::Actions.const_fetch action_locator_x
      hot = cls.new client_services
      r = hot.invoke par_h
      case r
      when true ; r = nil
      when false ; r = invt
      end
      EXITCODE_H__.fetch r do r end
    end
    SUCCESS_EXITSTATUS = 0
    GENERAL_FAILURE_EXITSTATUS = 8
    EXITCODE_H__ = {
      false => GENERAL_FAILURE_EXITSTATUS,
      nil => SUCCESS_EXITSTATUS }

    def invt
      progname = last_hot_prgm_name
      emit_info_line say { "try #{ kbd "#{ progname } -h" } for help" }
      false
    end

    def last_hot_prgm_name
      "#{ program_name } #{ Verb_lemma_hack_[ @downstream_action.class ] }"
    end

    def build_option_parser
      o = create_option_parser
      o.version = '0.0.1'         # avoid warnings from calling the builtin '-v'
      o.release = 'blood'         # idem
      o.on '-h', '--help', 'this screen, or help for particular action' do
        enqueue_help_as_box
      end
      o.summary_indent = '  '     # two spaces, down from four
      o
    end
    def create_option_parser
      Git::Services::OptionParser.new
    end
    def create_option_parser_for_leaf
      create_option_parser
    end

    # ~ CLI "the buck stops here" topper-stoppers

    # top-client #storypoint-5 is :#storypoint-8:
    # emitters at the top-client level merely write..

    def emit_payload_line s
      emit :payload, s
    end

    def emit_error_line s
      emit :_other_, s ; false
    end

    def emit_info_line s
      emit :_other_, s
    end

    # --*--

  public

    #                 ~ DSL line of demarcation ~

    Headless::CLI::Client[ self, :DSL ]

    option_parser do |o|
      o.separator " description: ping."
      o.on '--API' do
        @param_h[ :do_API ] = true
      end
      stashes_option o
      help_option o
    end

    def ping a, b=nil
      @param_h[ :_a ] = a ; @param_h[ :_b ] = b
      if @param_h[ :do_API ]
        ping_API
      else
        ping_CLI
      end
    end
  private
    def ping_CLI
      a, b = @param_h.values_at :_a, :_b
      if b
        emit_info_line "(#{ a }, #{ b })"
      elsif 'wrong' == a
        emit_error_line "this was wrong: #{ a.inspect }"
      else
        emit_payload_line "(#{ a })"
      end
      :ping_from_GSU
    end
    def ping_API
      @param_h.delete :do_API
      @param_h[ :zip ] = @param_h.delete :_a
      @param_h[ :zap ] = ( @param_h.delete :_b ) || false
      invoke_API :ping, @param_h
    end
  public

    option_parser do |o|
      o.separator " description: Shows the files that would be stashed."
      help_option o
      stashes_option o
      verbose_option o
      o
    end

    def status
      invoke_API :status, @param_h
    end

    option_parser do |o|
      o.separator " description: move all untracked files to #{
        }another folder (usu. outside of the project.)"
      dry_run_option o
      help_option o
      stashes_option o
      verbose_option o
      o
    end

    def save stash_name
      invoke_API :save, @param_h.merge( stash_name: stash_name )
    end

    option_parser do |o|

      o.separator " description: In the spirit of `git stash show`, #{
        }reports on contents of stashes."

      @param_h[ :is_in_color ] = true
      o.on( '--no-color', "No color." ) { @param_h[ :is_in_color ] = false }

      help_option o

      @param_h[ :do_show_patch ] = false
      o.on( '-p', '-u', '--patch', "Generate patch (can be used with --stat)."
        ) { @param_h[ :do_show_patch ] = true }

      stashes_option o

      @param_h[ :do_show_stat ] = false
      o.on( '--stat', "Show diffstat format (default) #{
        }(can be used with --patch)." ) { @param_h[ :do_show_stat ] = true }

      verbose_option o

      o
    end

    def show stash_name
      invoke_API :show, @param_h.merge( stash_name: stash_name )
    end

    option_parser do |o|
      o.separator " description: lists the \"stashes\" #{
        }(a glorified dir listing)."
      stashes_option o
      verbose_option o
      o
    end

    def list
      invoke_API :list, @param_h
    end

    option_parser do |o|
      o.separator  " description: Attempts to put the files back #{
        }if there are no collisions."
      dry_run_option o
      stashes_option o
      verbose_option o
      o
    end

    def pop stash_name
      invoke_API :pop, @param_h.merge( stash_name: stash_name )
    end

    module Services__
      class Find_Nearest_Hub  # this precededs "tree walker" [#ts-019]
        def initialize _
        end
        def call
          max_dirs = HARDCODED_MAX_DIRS__
          num_dirs_looked = 0
          pn = pwd_pn = ::Pathname.pwd
          while true
            max_dirs && num_dirs_looked >= max_dirs and break
            num_dirs_looked += 1
            (( pn_ = pn.join RELPATH__ )).exist? and break(( found_pn = pn ))
            parent_pn = pn.parent
            parent_pn == pn and break
            pn = parent_pn
          end
          if found_pn
            _relpath = pn_.relative_path_from pwd_pn
            hub = Hub_.new
            hub.hub_pathname = found_pn
            hub.stashes_pathname = _relpath
            hub
          else
            yield Not_Found__[ RELPATH__, pwd_pn, num_dirs_looked ]
          end
        end
        HARDCODED_MAX_DIRS__ = 5
        RELPATH__ = '../Stashes'.freeze
        Not_Found__ = ::Struct.new :relpath, :pwd, :d
      end
    end
  end
  Hub_ = ::Struct.new :hub_pathname, :stashes_pathname

  API = ::Module.new

  class API::Action

    Sub_client__[ self,
      :as_basic_set_via_params_const,
        :initialize_basic_set_with_hash,
        :basic_set_bork_event_listener_p, -> ev do
          emit_inner_error_string ev.string
        end,
      :emitters,
      :service_terminal, :intermediate,
      :verb_lemma_hack ]

    Headless::Client[ self, :client_services ]

    def initialize client
      @be_verbose = false ; @error_count = 0 ; @hub = nil
      client_notify client
      super()
    end

    client_services_class
    class Client_Services
      delegating :with_suffix, :_notify, %i(
        emit_inner_error_string emit_payload_line color_inquisition )
    end
    def emit_inner_error_string_notify s  # extreme emergencies
      emit_inner_error_string s
    end
    def emit_payload_line_notify s
      @client.emit_payload_line s
    end
    def color_inquisition_notify
      @is_in_color
    end

    def invoke par_h
      r = resolve_hub par_h
      r &&= initialize_basic_set_with_hash par_h
      if r
        Headless::CLI::PathTools.clear  # see notes at `pretty_path` - danger
        r = execute
      end ; r
    end

  private

    def resolve_hub par_h
      @hub and fail "sanity - hub is write once"
      stashes_s = par_h.fetch :stashes_path ; par_h.delete :stashes_path
      r = if stashes_s  # the old way - hub is pwd, both paths might be relative
        Hub_.new ::Pathname.new( '.' ), ::Pathname.new( stashes_s )
      else
        resolve_service( :find_nearest_hub ).call( & method( :nrst_hb_nt_fnd ) )

      end  # first, then derive hub abspath from it
      r and accept_normalized_hub r
    end

    def accept_normalized_hub hub
      @hub = hub
      @stashes_path = @hub.stashes_pathname.to_s
      true
    end

    def nrst_hb_nt_fnd ev
      relpath, pwd, d = ev.to_a
      reason_s = case 1 <=> d
      when -1 ; " and the #{ d - 1 } dirs above it"
      when  0 ; nil
      when  1 ; " (num dirs looked was #{ d }?)"  # (strange)
      end
      emit_inner_error_string say {
        "couldn't find #{ relpath } in #{ escape_path pwd }#{ reason_s }" }
    end

  public

  private

    # API action customizations of #storypoint-5

    def emit_inner_error_string s
      _l_s = self.class.verb_lemma_s
      a, s_, b = unparenthesize s
      emit_error_line "#{ a }failed to #{ _l_s } stash(es) - #{ s_ }#{ b }"
    end

    def emit_error_line s
      @error_count += 1
      super
    end

    def emit_inner_info_string s
      a, s_, b = unparenthesize s
      _l_s = self.class.verb_lemma_s
      emit_info_line "#{ a }while #{ _l_s }ing stash(es), #{ s_ }#{ b }"
    end

    def unparenthesize s
      md = PARENTHESES_RX__.match s
      if md
        [ md[ :a ], md[ :s ], md[ :b ] ]
      else
        [ nil, s, nil ]
      end
    end
    PARENTHESES_RX__ = %r{\A(?:
      (?<a>\() (?<s>.+) (?<b>\))  |
      (?<a>[#][ ]*) (?<s>.+) (?<b>)
    )\n?\z}x

    Headless::Action[ self,
      :anchored_names, :with, :name_waypoint_module, -> { API::Actions } ]

    def render_hub_info
      @hub.members.each do | i |
        emit_info_line "#{ i }: #{ @hub[ i ] }"
      end ; nil
    end

    # ~ API action business support

    def collection
      (( @collection_h ||= { } )).fetch @hub do |hub|
        # (`hub` struct generates keys as expected)
        @collection_h[ hub ] = build_collection
      end
    end
    # smell [#hl-027]: it could use model/view split. but only matters if we
    # ever have more than one API request processed in the same process

    def build_collection
      Stash__::Collection.new client_services,
        :stashes_pathname, @hub.stashes_pathname,
        :hub_pathname, @hub.hub_pathname,
        :channel_string_listener_p, -> i, str do
          fail self.do_me
          # define emit to sanitize paths from strings
          emit i, str.gsub( RX__ ) { escape_path $~[ 0 ] }
        end
    end
    RX__ = Headless::CLI::PathTools::FUN::ABSOLUTE_PATH_HACK_RX

  end

  # ~ :#storypoint-9 - experiments with extensions ..

  module FU_Bundle_and_IMs__
    Cd = -> _ do
      include Git::Services::FileUtils
    end
    Move = -> _ do
      include FU_Bundle_and_IMs__
    end
    Mkdir_p = Move
    Rmdir = Move
  private
    def move x1, x2, h
      _FU_agent.move x1, x2, h
    end
    def mkdir_p path_s, h
      _FU_agent.mkdir_p path_s, h
    end
    def rmdir path_s, h
      _FU_agent.rmdir path_s, h
    end
    def _FU_agent
      resolve_service( :FU_agent ).invoke nil, nil
    end
    MetaHell::Bundle::Multiset[ self ]
  end
  class API::Action
    class Client_Services
      delegating :to_method, :FU_agent_notify, :FU_agent
    end
    def FU_agent_notify
      @FU_agent ||= build_FU_agent
    end
  private
    def build_FU_agent
      Headless::IO::FU.new -> msg do
        emit_info_line "# #{ msg }"
      end
    end
  end

  #                               --*--

  module API::Actions
    MetaHell::Boxxy[ self, :deferred ]  # :#storypoint-10 placeholder
  end

  class API::Actions::Ping < API::Action

    Sub_client__[ self, :say ]

    PARAMS = %i( zip zap )

    def execute
      if @zap
        emit_inner_info_string "(#{ @zip })"
        zap = @zap
        _s = say { em zap }
        emit_inner_error_string "(pretending this was wrong: #{ _s })"
      else
        emit_payload_line "(out:#{ @zip })"
      end
      :pingback_from_API
    end
  end

  class Collecty__ < API::Action
    Sub_client__[ self, :popener3 ]
  private
    def normalized_relative_others
      cmd_s = CMD__
      ::Enumerator.new do |y|
        @be_verbose and emit_info_line cmd_s
        popen3 cmd_s do |_, sout, serr|
          loop do
            e = serr.read
            '' == e or break emit_error_string( "unexpected errput: #{ s }" )
            s = sout.gets
            s or break
            y << s.strip
          end
        end
      end
    end
    CMD__ = 'git ls-files --others --exclude-standard'
  end

  class API::Actions::Status < Collecty__

    Sub_client__[ self, :say ]

    PARAMS = %i( be_verbose stashes_path )

  private

    def execute
      @be_verbose and render_hub_info
      num = 0
      normalized_relative_others.each do |file_s|
        num += 1
        emit_payload_line file_s
      end
      num.zero? and emit_inner_info_string "(found no untracked files)"
      true
    end
  end

  class API::Actions::Save < Collecty__

    Sub_client__[ self, :popener3 ]

    PARAMS = %i( be_verbose dry_run stash_name stashes_path )

  private

    def execute
      @be_verbose and render_hub_info
      begin
        stash = collection.puff_stash_expected_to_be_writable @stash_name
        stash or break( r = stash )
        yes = false
        normalized_relative_others.each do |file_name|
          stash.stash_file file_name, @dry_run
          yes = true
        end
        yes or emit_inner_info_string "found no files to stash."
        r = true
      end while nil
      r
    end

    def normalized_relative_others
      cmd_s = CMD__
      ::Enumerator.new do |y|
        emit_info_line "# #{ cmd_s }"
        popen3 cmd_s do |_, sout, serr|
          loop do
            s = serr.read
            s.length.zero? or
              break emit_inner_error_string "unexpected errput: #{ s }"
            s = sout.gets
            s or break
            y << s.strip
          end
        end
      end
    end
    CMD__ = 'git ls-files --others --exclude-standard'
  end

  class API::Actions::Show < API::Action

    PARAMS = %i( be_verbose is_in_color do_show_patch do_show_stat
      stash_name stashes_path )

  private

    def execute
      stash = collection.puff_stash @stash_name
      @be_verbose and emit_inner_info_string "#{
        }(had stash path: #{ stash.pathname })"
      stash = stash.stash_expected_to_exist
      stash and with_extant_stash stash
    end

    def with_extant_stash stash
      ( @do_show_stat || @do_show_patch ) or @do_show_stat = true
      p = -> s do
        emit_payload_line s
      end
      @do_show_stat and stash.stat_lines.each( & p )
      @do_show_patch and stash.patch_lines.each( & p )
      true
    end
  end

  class API::Actions::List < API::Action

    Sub_client__[ self, :say ]

    PARAMS = %i( be_verbose stashes_path )

    def execute
      @be_verbose and render_hub_info
      @col = collection
      @col.expect_collection_exists and with_extant_collection
    end
  private
    def with_extant_collection
      @count = 0
      @col.stashes( @be_verbose ).each do |stash|
        @count += 1
        emit_payload_line stash.stash_name
      end
      @count.zero? ? none : some
    end
    def none
      pn = @stashes_path
      emit_inner_info_string say {
        "(no stashes found in #{ escape_path pn })"
      } ; nil
    end
    def some
      true
    end
  end

  class API::Actions::Pop < API::Action

    PARAMS = %i( be_verbose dry_run stash_name stashes_path )

    def execute
      @stash = collection.puff_stash( @stash_name ).stash_expected_to_exist
      @stash and with_stash
    end
  private
    def with_stash
      @stash.pop_stash @be_verbose, @dry_run
    end
  end

  #  ~ models / agents ~

  class Stash__

    Sub_client__[ self,
      :as_basic_set,
        :with_members, %i( hub_pathname stash_name stash_pathname ).freeze,
        :initialize_basic_set_with_iambic,
      :color_inquisitor ]

    def initialize client, * x_a
      initialize_basic_set_with_iambic x_a
      @quiet_h = { }
      client_notify client
      super()
      freeze
    end

    attr_reader :stash_name

    def pathname
      @stash_pathname
    end

    def stash_expected_to_exist
      if @stash_pathname.exist? then self else
        emit_error_string "Stash does not exist: #{ @stash_name }"
      end
    end

    def stash_expected_to_be_writable
      calculate_writing_validity ? self : false
    end
  private
    def calculate_writing_validity
      if @stash_pathname.exist?
        if (( dir_a = ::Dir[ "#{ @stash_pathname }/*" ] )).length.nonzero?
          emit_inner_error_string "destination dir must be empty #{
            }(\"stash\" already exists?). found files:\n#{ dir_a * "\n" }"
        else
          true  # empty dirs are valid for writing
        end
      elsif (( dir_pn = @stash_pathname.dirname )).exist?  # parent path must
        true  # exist. the child dir needs to be made, but not yet
      else
        emit_inner_error_string "stashes directory must exist: #{ dir_pn }"
      end
    end
  public

    def stat_lines
      ::Enumerator.new do |y|
        _p = -> line do
          y << line
        end
        Make_stat__[ @client, :stash_pn, @stash_pathname, :listener_p, _p ]
      end
    end

    def patch_lines
      ::Enumerator.new do |y|
        _p = -> line do
          y << line
        end
        is_in_color and _p = Add_colorizer__[ _p ]
        Make_patch__[ @client, @stash_pathname, _p ]
      end
    end

    def stash_file normalized_relative_file_name, is_dry_run
      Stash_file__[ @client, :filename_s, normalized_relative_file_name,
        :is_dry, is_dry_run, :quiet_h, @quiet_h, :stash_pn, @stash_pathname ]
    end

    def pop_stash be_verbose, dry_run
      Pop_stash__[ @client, :be_verbose, be_verbose, :dry_run, dry_run,
        :hub_pathname, @hub_pathname, :stash_pathname, @stash_pathname ]
    end
  end

  class Stash_file__

    Sub_client__[ self,
      :as_basic_set,
        :initialize_basic_set_with_iambic,
        :with_members, %i( filename_s is_dry quiet_h stash_pn ).freeze,
      :emitters,
      :funcy,
      :file_utils, :mkdir_p, :move
    ]

    def initialize client, * x_a
      initialize_basic_set_with_iambic x_a
      client_notify client
      super()
    end

    def execute
      @dest_pn = @stash_pn.join @filename_s
      if @dest_pn.exist?
        when_exist
      else
        when_not_exist
      end
    end
  private
    def when_exist
      emit_inner_error_string "destination file already existed in stash #{
        }location - #{ dest_pn }"
    end
    def when_not_exist
      @dn_pn = @dest_pn.dirname
      @dn_pn.exist? or quietly_mkdir_p
      r = move @filename_s, @dest_pn.to_s, verbose: true, noop: @is_dry
      r
    end
    def quietly_mkdir_p
      key_s = @dn_pn.to_s
      @quiet_h.fetch key_s do
        mkdir_p key_s, verbose: true, noop: @is_dry
        @quiet_h[ key_s ] = true
      end  ; nil
    end
  end

  class Pop_stash__

    Sub_client__[ self,
      :as_basic_set,
        :with_members, %i( be_verbose dry_run
          stash_pathname hub_pathname ).freeze,
        :initialize_basic_set_with_iambic,
      :file_utils,
        :mkdir_p, :move, :rmdir,
      :funcy, :popener3, :shellesc ]

    def initialize client, * x_a
      initialize_basic_set_with_iambic x_a
      client_notify client
      super()
    end

    def execute
      @existed_pn_a = nil
      @move_a = build_move_a
      if @existed_pn_a
        files_existed
      else
        target_paths_are_available
      end
    end

  private

    def build_move_a
      stashed_filenames.map do |fn_s|
        mov = Move__.new
        mov.source_pathname = @stash_pathname.join fn_s
        mov.dest_pathname = @hub_pathname.join fn_s
        mov.dest_pathname.exist? and
          (( @existed_pn_a ||= [] )) << mov.dest_pathname
        mov
      end
    end
    Move__ = ::Struct.new :source_pathname, :dest_pathname

    def stashed_filenames
      ::Enumerator.new do |y|
        cmd_s = "cd #{ shellesc @stash_pathname }; find . -type f"
        @be_verbose and emit_info_line "# #{ cmd_s }"
        _i, o, e, w = popen3 cmd_s
        s = e.gets and fail "wat: #{ s.inspect }"
        while (( s = o.gets ))
          y << DOT_SLASH_RX__.match( s )[ 0 ]
        end
       (( es = w.value.exitstatus )).zero? or fail "wat: #{ es }" ; nil
      end
    end
    DOT_SLASH_RX__ = %r{ (?<= \A \. / ) .* (?= \n\z ) }x

    def files_existed
      emit_inner_error_string "destination file(s) exist:"
      @existed_pn_a.each do |pn|
        emit_error_line "  #{ pn }"
      end
      false
    end

    def target_paths_are_available
      opt_h = { noop: @dry_run, verbose: true } # pop is always verbose
      @move_a.each do |mov|
        mov.dest_pathname.dirname.directory? or  # (always verbose when pop)
          mkdir_p mov.dest_pathname.dirname, opt_h
        move mov.source_pathname, mov.dest_pathname, opt_h
          # might fail during a dry run (if a dry mkdir_p above)
      end
      prune_directories
    end

    def prune_directories  # depth-first in reverse so we remove child dirs
      # before the parent dir that contains them
      stack_a = build_dirs_to_remove_s_stack_a
      opt_h = { noop: @dry_run, verbose: @be_verbose }
      while (( s = stack_a.pop ))
        rmdir s, opt_h
      end
      true
    end

    def build_dirs_to_remove_s_stack_a
      stack_a = [] ; cmd_s = "find #{ shellesc @stash_pathname } -type d"
      @be_verbose and emit_info_line "# #{ cmd_s }"
      _i, o, e, w = popen3 cmd_s
      s = e.gets and fail "wat: #{ s.inspect }"
      while (( s = o.gets ))  # depth-first
        stack_a << s.strip!
      end
      (( es = w.value.exitstatus )).zero? or raise "no: #{ es.inspect }"
      stack_a
    end
  end

  class Stash__::Collection

    Sub_client__[ self,
      :as_basic_set,
        :initialize_basic_set_with_iambic,
        :with_members, %i(
          channel_string_listener_p hub_pathname stashes_pathname
        ).freeze ]

    def initialize client, * x_a
      initialize_basic_set_with_iambic x_a
      @cache_h = { }
      client_notify client
      super()
      freeze
    end

    def expect_collection_exists
      if (( pn = @stashes_pathname )).exist? then true else
        emit_inner_error_string say {
          "stashes directory does not exist: #{ escape_path pn }" }
        false
      end
    end

    def puff_stash_expected_to_be_writable stash_name
      puff_stash( stash_name ).stash_expected_to_be_writable
    end

    def puff_stash name_x
      @cache_h[ name_x ] ||= build_stash name_x
    end
    def build_stash name_x
      Stash__.new( @client,
        :hub_pathname, @hub_pathname,
        :stash_name, name_x,
        :stash_pathname, @stashes_pathname.join( name_x ) )
    end

    def stashes be_verbose
      ::Enumerator.new do |y|
        @stashes_pathname.children( true ).each do |pn|  # or e.g. Errno::ENOENT
          if pn.directory?
            y << puff_stash( pn.basename.to_s )
          elsif be_verbose
            emit_inner_info_string say {
              "(not a directory: #{ escape_path pn })" }
          end ; nil
        end
      end
    end
  end

  class Make_patch__

    Sub_client__[ self,
      :file_utils, :cd,
      :funcy,
      :popener3 ]

    class << self
      alias_method :call, :[]
    end

    def initialize client, stash_pn, listener_p
      @listener_p = listener_p ; @stash_pn = stash_pn
      client_notify client
      super()
    end

    def execute
      pn = @stash_pn
      ::File.directory? pn or raise "not a directory: #{ pn }"
      i, o, e, w = nil
      cd pn do
        i, o, e, w = popen3 'find . -type f'
        s = e.gets and raise "nope: #{ s }"
        while (( s = o.gets ))
          s.chomp!
          emit_patch s
        end
        w.value.exitstatus.zero? or fail "uh-oh: #{ w.value.exitstatus }"
      end
      nil
    end
  private
    def emit_patch file_s
      Make_patch_for_file__[ @client, file_s, @listener_p ]
    end
  end

  class Make_patch_for_file__
    Sub_client__[ self, :emit_payload_line_to_listener, :funcy, :popener3 ]
    def initialize client, file_s, listener_p
      @file_s = file_s ; @listener_p = listener_p
      client_notify client
      super()
    end
    def execute
      _i, o, e, _w = popen3 'file', '--brief', @file_s
      s = e.gets and fail "no: #{ s.inspect }"
      @s = o.gets ; @s.chop!
      s_ = o.gets and fail "no: #{ s_.inspect }"
      if ASCII_RX__ =~ @s
        money
      else
        no
      end
    end
    ASCII_RX__ = /\AASCII\b/
  private
    def no
      @client.emit_inner_error_string "# skipping #{ @file_s }: #{ @s }"
    end
    def money
      line_a = File.read( @file_s ).split "\n", -1
      emit_payload_line '--- /dev/null'
      emit_payload_line "+++ #{ @file_s.sub %r(^\.), 'b' }"
      if '' == line_a.last
        line_a.pop
      else
        # ...
      end
      emit_payload_line "@@ -0,0 +1,#{ line_a.length } @@"
      line_a.each do |line|
        emit_payload_line "+#{ line }"
      end ; nil
    end
  end

  define_singleton_method :stylize, & Headless::CLI::Pen::FUN.stylize  # #posterity for below ancient lines

  PATCH_STYLE_P_A__ = [
    ->(s) { stylize(s, :strong, :red) },
    ->(s) { s.sub(/(@@[^@]+@@)/) { stylize($1, :cyan) } },
    ->(s) { stylize(s, :green) },
    ->(s) { stylize(s, :red) },
    ->(s) { s }
  ]

  PATCH_LINE_RX__ = %r{\A
    (--|\+\+|[^- @+]) |
    (@)               |
    (\+)              |
    (-)               |
    ( )
  }x

  PATCH_LINE_TYPE_I_A__ = %i( file_info chunk_numbers add remove context )

  Add_colorizer__ = -> lamb do  # stay ugly for [#bs-010] for now, also at this commit we removed another similar ugly
    -> line do
      lamb[ PATCH_STYLE_P_A__[ PATCH_LINE_RX__.match(line).captures.each_with_index.detect{ |s, i| ! s.nil? }[1]][line]]
    end
  end

  class Make_stat__

    Sub_client__[ self,
      :as_basic_set,
        :with_members, %i( listener_p stash_pn ).freeze,
        :initialize_basic_set_with_iambic,
      :color_inquisitor,
      :emit_payload_line_to_listener,
      :funcy,
      :say ]

    def initialize client, * x_a
      initialize_basic_set_with_iambic x_a
      client_notify client
      super()
    end

    def execute
      render_file_a build_file_a
    end

  private

    def build_file_a
      files = []
      Make_patch__.call @client, @stash_pn, -> line do
        md = PATCH_LINE_RX__.match line
        type_i = PATCH_LINE_TYPE_I_A__[md.captures.each_with_index.detect{ |s, | ! s.nil? }[1]]
        case type_i
        when :file_info
          if md = /^(?:(---)|(\+\+\+)) (.+)/.match(line)
            if md[1]
              '/dev/null' == md[3] or fail("hack failed: #{md[3].inspect}")
            else
              md2 = /^b\/(.+)$/.match(md[3]) or fail("hack failed: #{md[3].inspect}")
              files.push Filecount__.new( md2[1], 0, 0, 0 )
            end
          end # else ignored some kinds of fileinfo
        when :chunk_numbers
          md = /^@@ -\d+,(\d+) \+\d+,(\d+) @@$/.match(line) or fail("failed to match chunk: #{line.inspect}")
          files.last.deletions += md[1].to_i
          files.last.insertions += md[2].to_i
        when :add, :remove, :context # ignored
        else fail("unhandled line pattern or type (line type: #{type_i.inspect})")
        end
      end
      files
    end
    Filecount__ = Struct.new :name, :insertions, :deletions, :combined

    def render_file_a files
      name_max = combined_max = 0
      plusminus_width = 40
      total_inserts = total_deletes = 0
      files.each do |f|
        total_inserts += f.insertions
        total_deletes += f.deletions
        f.combined = f.insertions + f.deletions
        f.name.length > name_max and name_max = f.name.length
        f.combined > combined_max and combined_max = f.combined
      end
      plusminus_width > combined_max and plusminus_width = combined_max # do not scale down with small numbers
      col2width = combined_max.to_s.length
      format = "%-#{name_max}s | %#{col2width}s %s"
      combined_max == 0  and combined_max = 1 # avoid divide by zero, won't matter at this point to change it
      files.each do |f|
        num_pluses = (f.insertions.to_f / combined_max * plusminus_width).ceil # have at least 1 plus if nonzero
        num_minuses = (f.deletions.to_f / combined_max * plusminus_width).ceil
        pluses =  '+' * num_pluses
        minuses = '-' * num_minuses
        if is_in_color
          pluses = say{ stylize pluses, :green }
          minuses = say{ stylize minuses, :green }
        end
        emit_payload_line format %
          [ f.name, f.combined, "#{ pluses }#{ minuses }" ]
      end
      emit_payload_line "%s files changed, %d insertions(+), %d deletions(-)" %
        [ files.count, total_inserts, total_deletes ]
    end
  end
end

# [#bs-001] 'reaction-to-assembly-language-phase' phase
