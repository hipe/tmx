module Skylab::Git

  class Models_::Stow  # see [#010]

    # (old code has indention that is typically one tab stop too little.)

  if false  # (( BEGIN OFF

  class CLI

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

    SUCCESS_EXITSTATUS = 0
    GENERAL_FAILURE_EXITSTATUS = 8
    EXITCODE_H__ = {
      false => GENERAL_FAILURE_EXITSTATUS,
      nil => SUCCESS_EXITSTATUS }

    def build_option_parser
      o = begin_option_parser
      o.version = '0.0.1'         # avoid warnings from calling the builtin '-v'
      o.release = 'blood'         # idem
      o.on '-h', '--help', 'this screen, or help for particular action' do
        enqueue_help_as_box
      end
      o.summary_indent = '  '     # two spaces, down from four
      o
    end

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
      class Find_Nearest_Hub  # :+[#sy-018] this precededs "tree walker"
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

  end  # END OFF ))

    Bz__ = Home_.lib_.brazen

    class Action_ < Bz__::Action

      Bz__::Model::Entity.call self

    end

    Actions = ::Module.new

    class Actions::Ping < Action_

      @is_promoted = true

      edit_entity_class(
        :property, :zip,
        :property, :zap,
      )

      def produce_result

        h = @argument_box.h_
        if h[ :zap ]
          emit_inner_info_string "(#{ @zip })"
          zap = @zap
          _s = say { em zap }
          emit_inner_error_string "(pretending this was wrong: #{ _s })"

        else

          @on_event_selectively.call :payload, :expression, :ping do | y |
            y << "(out: #{ h[ :zip ] })"
          end
        end

        :pingback_from_API
      end
    end

  class Actions::Save < Action_

    # Sub_client__[ self, :popener3 ]

    PARAMS = %i( be_verbose dry_run stash_name stashes_path )

    def ___WAS_execute
      @be_verbose and render_hub_info
      begin
        stash = collection.touch_stash_expected_to_be_writable @stash_name
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

    class Actions::Show < Action_

      edit_entity_class(
        :required, :property, :filesystem,
        :required, :property, :system_conduit,
        :required, :property, :stows_path,
        :required, :property, :stow_name,
      )

      def produce_result

        h = @argument_box.h_

        _col = @kernel.silo( :stow ).stows_collection_via_path(
          h.fetch( :stows_path ),
          & @on_event_selectively )

        stow = _col.entity_via_intrinsic_key h.fetch :stow_name
        if stow
          Stow_::Models_::Expressive_Stow.new(
            :yes_color,
            stow,
            h.fetch( :system_conduit ),
            h.fetch( :filesystem ),
            & @on_event_selectively )
        else
          stow
        end
      end
    end

    class Actions::Status < Action_

      edit_entity_class(
        :required, :property, :system_conduit,
        :required, :property, :stows_path,
        :required, :property, :directory,
      )

      def produce_result

        were_events = false
        oes_p = -> * i_a, & ev_p do
          were_events = true
          @on_event_selectively.call( * i_a, & ev_p )
        end

        st = @kernel.silo( :stow ).stows_collection_via_path(
          @argument_box.fetch( :stows_path ),
          & oes_p ).to_entity_stream

        st.gets  # doesn't matter if there are no entities

        if were_events
          UNABLE_
        else
          __hit_the_system
        end
      end

      def __hit_the_system

        h = @argument_box.h_

        _vd = @kernel.silo( :stow ).versioned_directory_via(
          h.fetch( :directory ),
          h.fetch( :system_conduit ),
          & @on_event_selectively )

        _vd.to_entity_stream
      end
    end

    class Actions::List < Action_

      edit_entity_class(
        :required, :property, :stows_path,
      )

    def produce_result

      _silo = @kernel.silo( :stow )

      _col = _silo.stows_collection_via_path(
        @argument_box.fetch( :stows_path ),
        & @on_event_selectively )

      _col.to_entity_stream
    end
  end

  class Actions::Pop < Action_

    PARAMS = %i( be_verbose dry_run stash_name stashes_path )

    def __WAS_execute
      @stash = collection.touch_stash( @stash_name ).stash_expected_to_exist
      @stash and with_stash
    end

  private

    def with_stash
      @stash.pop_stash @be_verbose, @dry_run
    end
  end

    class Silo_Daemon

      def initialize k, _model_class
        @kernel = k
      end

      def stows_collection_via_path path, & oes_p  # like `entity_via_intrinsic_key`

        # (we could cache each collection per path, but instead we bind the
        # collection to the event handler, making it a "collection controller")

        Stow_::Models_::Collection.new path, @kernel, & oes_p
      end

      def versioned_directory_via d, sc, & oes_p

        Stow_::Models_::Versioned_Directory.__new d, sc, @kernel, & oes_p
      end
    end

    Autoloader_[ ( Models_ = ::Module.new ), :boxxy ]

    Stow_ = self

    class Stow_

      attr_reader(
        :path,
      )

      class << self

        def new_flyweight k, & oes_p
          o = new k, & oes_p
          o.__init_as_flyweight
          o
        end
      end

      def initialize k, & oes_p

        # NOTE might be a an entity, might be a UI node!
        @kernel = k
        @on_event_selectively = oes_p
      end

      def __init_as_flyweight
        NIL_
      end

      def reinitialize_via_path_for_directory_as_collection path
        @path = path
        NIL_
      end

      def get_stow_name
        ::File.basename @path
      end
    end

  class WAS_Stow

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

    def patch_lines
      ::Enumerator.new do |y|
        _p = -> line do
          y << line
        end
        is_in_color and _p = Add_colorizer__[ _p ]
        Actors_::Build_patch[ @client, @stash_pathname, _p ]
      end
    end

    def stash_file normalized_relative_file_name, is_dry_run

      Actors__::Stash_file.with(
        :client, @client,
        :filename_s, normalized_relative_file_name,
        :is_dry, is_dry_run,
        :quiet_h, @quiet_h,
        :stash_pn, @stash_pathname,
      )
    end

    def pop_stash be_verbose, dry_run

      Actors__::Pop_stash.with(
        :client, @client,
        :be_verbose, be_verbose,
        :dry_run, dry_run,
        :hub_pathname, @hub_pathname,
        :stash_pathname, @stash_pathname,
      )
    end
  end

    Actors__ = ::Module.new

  class Actors__::Stash_file

    if false
    Sub_client__[ self,
      :as_basic_set,
        :initialize_basic_set_with_iambic,
        :with_members, %i( filename_s is_dry quiet_h stash_pn ).freeze,
      :emitters,
      :globless_actor,
      :file_utils, :mkdir_p, :move
    ]
    end

    def initialize x_a
      client = x_a.shift
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

  class Actors__::Pop_stash

    if false
    Sub_client__[ self,
      :as_basic_set,
        :with_members, %i( be_verbose dry_run
          stash_pathname hub_pathname ).freeze,
        :initialize_basic_set_with_iambic,
      :file_utils,
        :mkdir_p, :move, :rmdir,
      :globless_actor, :popener3, :shellesc ]
    end

    def initialize x_a
      client = x_a.shift
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
# ->
  end
end

# [#bs-001] 'reaction-to-assembly-language-phase' phase :+#tombstone:
# :+#tombstone: #storypoint-3
