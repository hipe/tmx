require_relative '..'

require 'skylab/headless/core'

module Skylab::GitStashUntracked

  Autoloader = ::Skylab::Autoloader  # (doing these explicitly is actually
  GitStashUntracked = self        # less typing and less ambiguous than
  Headless = ::Skylab::Headless   # including ::Skylab all over the place)
  MetaHell = ::Skylab::MetaHell

  extend Autoloader               # for our one other file..



  module SubClient_InstanceMethods
    include Headless::SubClient::InstanceMethods

    # (no public methods defined in this module)

  protected # (protected before public this file only to reduce "strain" on DSL)

    def initialize request_client
      _gsu_sub_client_init! request_client
    end

    def _gsu_sub_client_init! request_client
      @emit = nil
      _headless_sub_client_init! request_client
      nil
    end

    def emit type, msg            # experimental customizable emit
      if @emit
        @emit[ type, msg ]
      else
        request_client.send :emit, type, msg
      end
    end

    def info msg                  # (just like ancestor but decorated)
      emit :info, "# #{ msg }"
      nil
    end

    def stylize *a                # away at [#hl-029]
      pen.stylize(* a )
    end
  end



  module Color_InstanceMethods
    def color?
      request_client.send :color?
    end
  end



  module PathInfo_InstanceMethods

  protected

    relpath = '../Stashes'
    define_method :find_closest_path_info do
      res = nil
      begin
        curr = pwd = ::Pathname.pwd
        found = nil
        max_dirs_looked = nil                  # #placeholder for possible feat.
        num_dirs_looked = 0
        loop do
          if max_dirs_looked && max_dirs_looked >= num_dirs_looked
            break
          end
          num_dirs_looked += 1
          if curr.join( relpath ).exist?
            found = curr
            break
          end
          parent = curr.parent
          if parent == curr
            break
          end
          curr = parent
        end
        if found
          res = PathInfo.new curr, curr.join( relpath )
          break
        end
        reason = case 1 <=> num_dirs_looked
        when -1 ; " and the #{ num_dirs_looked - 1 } dirs above it"
        when  0 ; nil
        when  1 ; " num_dirs_looked was #{ num_dirs_looked }!" # (strange)
        end
        error "couldn't find #{ relpath } in #{ escape_path pwd }#{
          }#{ reason }"
        res = false
      end while nil
      res
    end

    attr_reader :path_info

    def resolve_path_info! param_h
      res = nil
      begin
        fail 'sanity - path info already set' if path_info
        sp = param_h.fetch :stashes_path       # yep, it must exist as a key
        param_h.delete :stashes_path           # mutate now, sure why not #atom
        if sp
          res = PathInfo.new ::Pathname.new( '.' ), ::Pathname.new( sp )
                                               # this is the "old way" where
                                               # anchor is pwd, both relative
        else
          res = find_closest_path_info         # this is the "new way", anchor
                                               # will be based on where stashes
        end                                    # was found.
        res or break
        @path_info = res
        res = true
      end while nil
      res
    end

    def stashes_path                          # for compat. with invoke impl,
      path_info.stashes_pathname.to_s         # we've got to be able to return
                                              # a non-nil value for any of these
    end                                       # that we absorb early (for now)
  end



  class CLI
    include SubClient_InstanceMethods          # *before* cli client mechanics
                                               # if you want to override them.

  protected                                    # (meh before we load DSL)

    def initialize _, stdout, stderr
      self.io_adapter = build_io_adapter _, stdout, stderr
      _gsu_sub_client_init! nil
    end

    def api_invoke mixed_action_name, param_h
      klass = API::Actions.const_fetch mixed_action_name
      o = klass.new self
      res = o.invoke param_h
      res
    end

    def build_option_parser
      o = GitStashUntracked::Services::OptionParser.new
      o.version = '0.0.1'         # avoid warnings from calling the builtin '-v'
      o.release = 'blood'         # idem
      o.on '-h', '--help', 'this screen, or help for particular action' do
        box_enqueue_help!
      end
      o.summary_indent = '  '     # two spaces, down from four
      o
    end

    define_method :escape_path, & Headless::CLI::PathTools::FUN.pretty_path
    protected :escape_path


    pen = Headless::CLI::Pen::MINIMAL

    define_method( :pen ) { pen }
    protected :pen


    # --*--

    def dry_run_option o
      param_h[:dry_run] = false
      o.on '-n', '--dry-run', "Dry run." do
        param_h[:dry_run] = true
      end
      nil
    end

    def help_option o
      o.on '-h', '--help', 'this screen' do
        enqueue_help!
      end
      nil
    end

    def verbose_option o
      param_h[:verbose] = false
      o.on '-v', '--verbose', 'verbose output' do
        param_h[:verbose] = true
      end
      nil
    end

    def stashes_option o
      param_h[:stashes_path] = nil
      o.on '-s', '--stashes <path>',
        "use <path> as stashes path and pwd as anchor dir" do |v|
        param_h[:stashes_path] = v
      end
    end

  public

    extend Headless::CLI::Client::DSL # methods defined below this, when
                                  # following an option parser def, constitute
                                  # the extent of this CLI's actions.

    build_option_parser do
      o = GitStashUntracked::Services::OptionParser.new
      o.separator " description: move all untracked files to #{
        }another folder (usu. outside of the project.)"
      dry_run_option o
      help_option o
      stashes_option o
      verbose_option o
      o
    end

    def save stash_name
      api_invoke :save, param_h.merge( stash_name: stash_name )
    end



    build_option_parser do
      o = GitStashUntracked::Services::OptionParser.new
      o.separator " description: lists the \"stashes\" #{
        }(a glorified dir listing)."
      stashes_option o
      verbose_option o
      o
    end

    def list
      api_invoke :list, param_h
    end



    build_option_parser do
      o = GitStashUntracked::Services::OptionParser.new

      o.separator " description: In the spirit of `git stash show`, #{
        }reports on contents of stashes."

      param_h[:color] = true
      o.on( '--no-color', "No color." ) { param_h[:color] = false }

      help_option o

      param_h[:show_patch] = nil
      o.on( '-p', '-u', '--patch', "Generate patch (can be used with --stat)."
        ) { param_h[:show_patch] = true }

      stashes_option o

      param_h[:show_stat] = nil
      o.on( '--stat', "Show diffstat format (default) #{
        }(can be used with --patch)." ) { param_h[:show_stat] = true }

      verbose_option o

      o
    end

    def show stash_name
      api_invoke :show, param_h.merge( stash_name: stash_name )
    end



    build_option_parser do
      o = GitStashUntracked::Services::OptionParser.new
      o.separator  " description: Attempts to put the files back #{
        }if there are no collisions."
      dry_run_option o
      stashes_option o
      verbose_option o
      o
    end

    def pop stash_name
      api_invoke :pop, param_h.merge( stash_name: stash_name )
    end



    build_option_parser do
      o = GitStashUntracked::Services::OptionParser.new
      o.separator " description: Shows the files that would be stashed."
      help_option o
      stashes_option o
      verbose_option o
      o
    end

    def status
      api_invoke :status, param_h
    end
  end



  module API
    # empty.
  end



  class API::Action
    include SubClient_InstanceMethods


    pathify = Autoloader::Inflection::FUN.pathify

    define_singleton_method :normalized_action_name do
      name[ API::Actions.name.length + 2  .. -1 ].
        split( '::' ).map{ |x| pathify[ x ].intern }
    end

    def invoke param_h
      res = nil
      begin
        res = resolve_path_info!( param_h ) or break
        res = set!( param_h ) or break
        Headless::CLI::PathTools.clear # see notes at `pretty_path` - danger
        res = execute
      end while nil
      res
    end

  protected

    # (initialize defined in sub-client i.m)

    fun = Headless::CLI::PathTools::FUN
    absolute_path_hack_rx = fun.absolute_path_hack_rx

    define_method :collection do
      @collection_cache ||= { }                # (using `path_info` struct as
      @collection_cache.fetch( path_info ) do |k| # a key works as expected.)
        c = Stash::Collection.new self, path_info, -> type, str do # define emit
          use = str.gsub absolute_path_hack_rx do # as: scan for strings that
            escape_path $~[0]                  # look like paths and escape them
          end                                  # using oure escape_path method
          emit type, use                       # and emit thru our emit method
        end
        @collection_cache[k] = c               # (smell [#hl-027]: it could
      end                                      # use model/view split. but
    end                                        # only important if we ever
                                               # have multiple api actions
                                               # happen in one process)

    def escape_path x                          # if in verbose mode,
      res = nil                                # do not do the fancy
      if verbose                               # path escaping, just show raw,
        res = x                                # long paths.
      else
        res = request_client.send :escape_path, x # otherwise, let the modality
      end                                      # client (e.g.) decide how
      res
    end

    def formal_param_a
      self.class.const_get :PARAMS, false
    end

    def normalized_action_name
      self.class.normalized_action_name
    end

    def popen3 cmd, &block
      GitStashUntracked::Services::Open3.popen3 cmd, &block
    end

    def set! param_h
      res = nil
      begin
        before = error_count
        missing_a = formal_param_a - param_h.keys
        invalid_a = param_h.keys - formal_param_a
        error = -> msg do
          self.error "can't invoke api action \"#{
            }#{ normalized_action_name.join ' ' }\" - #{ msg }"
        end
        if invalid_a.length.nonzero?
          error[ "invalid parameter(s): (#{ invalid_a.join ', ' })" ]
          break( res = false )
        end
        if missing_a.length.nonzero?           # #experimental addition to the
          missing_a.each_with_index do |k, i|  # canonical algorithm: allow
            if ! send( "#{ k }" ).nil?         # these to be previously set
              missing_a[i] = nil
            end
          end
          missing_a.compact!
        end
        if missing_a.length.nonzero?
          error[ "missing required parameter(s): (#{ missing_a.join ', ' })" ]
          break( res = false )
        end
        param_h.each { |k, v| send "#{ k }=", v } # might trigger error()
        res = error_count == before            # (better to keep it strict)
      end while nil
      res
    end

    def show_info
      path_info.members.each do |member|
        info "#{ member }: #{ path_info[member] }"
      end
      nil
    end

    def stashes_path= str
      if path_info
        fail "sanity - attempt to set stashes_path after path_info set."
      end
      self.path_info = StashesPathInfo.new str
      str
    end

    def verbose                                # if a given action doesn't
      true                                     # support this, we fallback to
    end                                        # "loud" for the above
  end


  #                               --*--

  module API::Actions
    extend MetaHell::Boxxy                     # (`const_fetch`)
  end


  class API::Actions::Save < API::Action
    include PathInfo_InstanceMethods

    PARAMS = [ :dry_run, :stash_name, :stashes_path, :verbose ]

  protected

    def execute
      show_info if verbose
      result = nil
      begin
        stash = collection.stash_valid_for_writing stash_name
        if ! stash
          break( result = stash )
        end
        any = false
        normalized_relative_others.each do |file_name|
          stash.stash_file file_name, dry_run
          any = true
        end
        if ! any
          info "no files to stash!"
        end
        result = true
      end while nil
      result
    end

  protected

    attr_accessor :dry_run, :stash_name, :verbose

    command_s = 'git ls-files --others --exclude-standard'

    define_method :normalized_relative_others do
      ::Enumerator.new do |y|
        info command_s
        popen3 command_s do |_, sout, serr|
          loop do
            e = serr.read
            if '' != e
              error e
              break
            end
            line = sout.gets
            break if ! line
            y << line.strip
          end
        end
      end
    end
  end



  class API::Actions::Status < API::Actions::Save

    PARAMS = [ :stashes_path, :verbose ]

  protected

    def execute
      res = nil
      begin
        show_info if verbose
        num = 0
        normalized_relative_others.each do |file_name|
          num += 1
          payload file_name
        end
        if 0 == num
          info "(no untracked files)"
        end
        res = true
      end while nil
      res
    end
  end



  class API::Actions::List < API::Action
    include PathInfo_InstanceMethods

    PARAMS = [ :stashes_path, :verbose ]

  protected

    def execute
      res = nil
      begin
        show_info if verbose
        if ! collection.validate_existence
          break( res = false )
        end
        count = 0
        collection.stashes( verbose ).each do |stash|
          count += 1
          emit :payload, stash.stash_name
        end
        res = count
      end while nil
      res
    end

    # --*--

    attr_accessor :verbose

  end



  class API::Actions::Show < API::Action
    include PathInfo_InstanceMethods

    PARAMS = [ :color, :show_patch, :show_stat, :stash_name,
                 :stashes_path, :verbose ]
  protected

    def execute
      res = nil
      begin
        stash = collection.stash stash_name
        if verbose
          info "(stash path: #{ stash.send :pathname })"
        end
        stash = stash.validate_existence
        if ! stash
          break( res = stash )
        end
        if ! (show_stat || show_patch)
          self.show_stat = true
        end
        if show_stat
          stash.stat_lines.each do |type, string|
            emit type, string
          end
        end
        if show_patch
          stash.patch_lines.each do |type, string|
            emit type, string
          end
        end
      end while nil
      res
    end

  protected

    attr_accessor :color, :stash_name, :show_patch, :show_stat, :verbose
    alias_method :color?, :color # api compat

  end



  class API::Actions::Pop < API::Action
    include Color_InstanceMethods
    include PathInfo_InstanceMethods

    PARAMS = [ :dry_run, :stash_name, :stashes_path, :verbose ]

  protected

    def execute
      res = nil
      begin
        stash = collection.stash( stash_name ).validate_existence
        break( res = false ) if ! stash
        stash.pop dry_run, verbose, method( :emit )
      end while nil
      res
    end

    attr_accessor :dry_run, :stash_name, :verbose
  end


  # --*--


  class PathInfo < ::Struct.new :anchor_pathname, :stashes_pathname
  end


  class Stash
    include GitStashUntracked::Services::FileUtils
    include SubClient_InstanceMethods
    include Color_InstanceMethods

    def patch_lines
      ::Enumerator.new do |y|
        emit = -> type, line do
          y <<  [type, line]
        end
        if color?
          emit = ColorizedPatch[ emit ]
        end
        MakePatch[ pathname, emit ]
      end
    end

    def stat_lines
      ::Enumerator.new do |y|
        MakeStat[ self, pathname, -> type, msg { y << [type, msg] } ]
      end
    end

    move_struct = ::Struct.new :source_pathname, :dest_pathname
    define_method :pop do |dry_run, verbose, emit|
      res = nil
      begin
        existed = nil
        moves = filenames( verbose ).map do |filename|
          o = move_struct.new
          o.source_pathname = pathname.join filename
          o.dest_pathname = path_info.anchor_pathname.join filename
          if o.dest_pathname.exist?
            ( existed ||= [] ).push o.dest_pathname
          end
          o
        end
        if existed
          emit[ :error, "Can't pop, destination file(s) exist:" ]
          existed.each { |pn| emit[ :error, pn.to_s ] }
          break( res = false )
        end
        moves.each do |o|
          if ! o.dest_pathname.dirname.directory? # (always verbose when pop)
            mkdir_p o.dest_pathname.dirname, noop: dry_run, verbose: true
          end
          mv o.source_pathname, o.dest_pathname, noop: dry_run, verbose: true
            # might fail during a dry run (if a dry mkdir_p above)
        end
        prune_directories dry_run, verbose
        res = true
      end while nil
      res
    end

    def stash_file normalized_relative_file_name, dry_run
      res = nil
      begin
        if ! valid_for_writing?
          break( res = false )
        end
        dest = pathname.join normalized_relative_file_name
        if ! dest.dirname.exist?
          @quiet.fetch dest.dirname.to_s do |dir_path|
            mkdir_p dir_path, verbose: true, noop: dry_run
            @quiet[dir_path] = true
          end
        end
        res = move normalized_relative_file_name, dest.to_s, verbose: true, noop: dry_run
      end while nil
      res
    end

    attr_reader :stash_name

    # save below as-is for #posterity /slash/ you-know-what
    def validate_existence
      res = false
      begin
        break( res = self ) if pathname.exist?
        error "Stash does not exist: #{ stash_name }"
      end while nil
      res
    end

    def valid_for_writing?
      if @valid_for_writing.nil?
        validate_for_writing!
      end
      @valid_for_writing
    end

  protected

    def initialize request_client, path_info, stash_name, emit
      _gsu_sub_client_init! request_client
      @emit = emit
      @path_info = path_info
      @pathname = path_info.stashes_pathname.join stash_name
      @quiet = { }
      @stash_name = stash_name
      @valid_for_writing = nil
    end

    def filenames verbose
      ::Enumerator.new do |o|
        cmd = "cd #{ pathname }; find . -type f"
        info( cmd ) if verbose
        GitStashUntracked::Services::Open3.popen3( cmd ) do |_, sout, serr|
          '' != (s = serr.read) and fail("uh-oh: #{s}")
          while s = sout.gets
            o << %r{^\./(.*)$}.match(s)[1]
          end
        end
      end
    end

    def fu_output_message msg
      @emit[ :info, "#{ msg }" ]
    end

    attr_reader :path_info

    attr_reader :pathname

    def prune_directories dry_run, verbose
      stack = []
      cmd = "find #{ pathname } -type d"
      info( cmd ) if verbose
      GitStashUntracked::Services::Open3.popen3 cmd do |_, sout, serr|
        while s = sout.gets                    # depth-first
          stack.push s.strip
        end
      end

      while s = stack.pop                      # depth-first reversed, so that
        rmdir s, verbose: verbose, noop: dry_run # we remove child dirs before
      end                                      # the parent dir that
    end                                        # contains them

    def validate_for_writing!
      valid = nil
      begin
        dir_pathname = pathname.dirname
        if pathname.exist?
          dir = ::Dir[ "#{ pathname }/*" ]
          if dir.any?
            error "Destination dir must be empty (\"stash\" already exists?).#{
              } Found files:\n#{ dir.join "\n" }"
            valid = false
          else
            valid = true          # empty dirs are valid for writing, sure
          end
        elsif dir_pathname.exist? # parent path must exist
          valid = true            # the child dir needs to be made, but not yet
        else
          error "Stashes directory must exist: #{ dir_pathname }"
          valid = false
        end
      end while nil
      @valid_for_writing = valid
      nil
    end
  end



  class Stash::Collection
    include SubClient_InstanceMethods
    include Color_InstanceMethods

    def stash stash_name
      @cache[stash_name] ||= Stash.new self, path_info, stash_name, @emit
    end

    def stash_valid_for_writing stash_name
      stash = self.stash stash_name
      if stash.valid_for_writing?
        stash
      else
        false
      end
    end

    def stashes verbose
      ::Enumerator.new do |y|
        pathname.children( true ).each do |child| # or e.g. Errno::ENOENT
          if child.directory?
            stash = self.stash child.basename.to_s
            y << stash
          else
            info "(not a directory: #{ escape_path child })" if verbose
          end
        end
      end
    end

    def validate_existence
      res = nil
      if pathname.exist?
        res = true
      else
        @emit[ :error, "Stashes dir does not exist: #{ pathname }" ]
        res = false
      end
      res
    end

  protected

    def initialize request_client, path_info, emit
      _gsu_sub_client_init! request_client
      @cache = { }
      @emit = emit
      @path_info = path_info
    end

    attr_reader :path_info

    def pathname
      @path_info.stashes_pathname
    end
  end



  module MakePatch
    # singleton hack! (is a module only so the name shows up appropriately)
  end



  class << MakePatch
    include GitStashUntracked::Services::FileUtils

    def call path, emit
      ::File.directory?( path ) or raise "not a directory: #{ path }"
      each_path = ->(file) do
        begin
          lines = File.read(file).split("\n", -1)
          emit[:payload, '--- /dev/null']
          emit[:payload, "+++ #{file.sub(/^\./, 'b')}"]
          if '' == lines.last
            lines.pop
          else
            # ...
          end
          emit[:payload, "@@ -0,0 +1,#{lines.count} @@"]
          lines.each { |line| emit[:payload, "+#{line}"] }
        rescue ::ArgumentError => e
          emit[:error, "failed to hack a diff for file. binary file? (#{path})"]
        end
      end
      cd(path) do
        GitStashUntracked::Services::Open3.popen3('find . -type f') do |_, sout, serr|
          '' != (s = serr.read) and raise("nope: #{s}")
          while s = sout.gets do each_path[s.strip] end
        end
      end
    end

    alias_method :[], :call       # `call` for multiline, `[]` for single
  end

  # the below is so wrong but we are doing it for posterity to make the
  # old code work below it
  define_singleton_method :stylize, & Headless::CLI::Pen::FUN[:stylize]

  PATCH_STYLES = [
    ->(s) { stylize(s, :strong, :red) },
    ->(s) { s.sub(/(@@[^@]+@@)/) { stylize($1, :cyan) } },
    ->(s) { stylize(s, :green) },
    ->(s) { stylize(s, :red) },
    ->(s) { s }
  ]

  PATCH_LINE = %r{\A
    (--|\+\+|[^- @+]) |
    (@)               |
    (\+)              |
    (-)               |
    ( )
  }x

  PATCH_LINE_TYPES = [
    :file_info,
    :chunk_numbers,
    :add,
    :remove,
    :context
  ]

  ColorizedPatch = -> lamb do
    -> type, line do
      lamb[type, PATCH_STYLES[PATCH_LINE.match(line).captures.each_with_index.detect{ |s, i| ! s.nil? }[1]][line]]
    end
  end



  class MakeStat
    include SubClient_InstanceMethods
    include Color_InstanceMethods

    def self.[] pathname, pen, emit
      o = new pathname, pen, emit
      o.run
    end

  public

    def run
      _render _calculate
    end

  protected

    def initialize request_client, pathname, emit
      _gsu_sub_client_init! request_client
      @emit = emit
      @pathname = pathname
    end

    def _calculate
      filecount = Struct.new :name, :insertions, :deletions, :combined
      files = []
      MakePatch.call @pathname, -> type, line do
        md = PATCH_LINE.match line
        type = PATCH_LINE_TYPES[md.captures.each_with_index.detect{ |s, i| ! s.nil? }[1]]
        case type
        when :file_info
          if md = /^(?:(---)|(\+\+\+)) (.+)/.match(line)
            if md[1]
              '/dev/null' == md[3] or fail("hack failed: #{md[3].inspect}")
            else
              md2 = /^b\/(.+)$/.match(md[3]) or fail("hack failed: #{md[3].inspect}")
              files.push filecount.new(md2[1], 0, 0, 0)
            end
          end # else ignored some kinds of fileinfo
        when :chunk_numbers
          md = /^@@ -\d+,(\d+) \+\d+,(\d+) @@$/.match(line) or fail("failed to match chunk: #{line.inspect}")
          files.last.deletions += md[1].to_i
          files.last.insertions += md[2].to_i
        when :add, :remove, :context # ignored
        else fail("unhandled line pattern or type (line type: #{type.inspect})")
        end
      end
      files
    end

    def _render files
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
        if color?
          pluses = stylize pluses, :green
          minuses = stylize minuses, :red
        end
        @emit[:payload, (format % [f.name, f.combined, "#{pluses}#{minuses}"])]
      end
      @emit[:payload, ("%s files changed, %d insertions(+), %d deletions(-)" % [files.count, total_inserts, total_deletes])]
    end
  end
end
