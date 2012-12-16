require_relative '..'

require 'skylab/headless/core'
require 'skylab/porcelain/all' # EVIL

module Skylab::GitStashUntracked

  Autoloader = ::Skylab::Autoloader  # (doing these explicitly is actually
  GitStashUntracked = self        # less typing and less ambiguous than
  Headless = ::Skylab::Headless   # including ::Skylab all over the place)
  MetaHell = ::Skylab::MetaHell
  Porcelain = ::Skylab::Porcelain

  extend Autoloader               # for our one other file..



  module SubClient_InstanceMethods

    # (no public methods defined in this module)

  protected

    def initialize request_client
      _gsu_sub_client_init! request_client
    end

    def _gsu_sub_client_init! request_client
      @emit = nil
      @error_count = 0
      @request_client = request_client
      nil
    end

    def emit type, msg            # experimental customizable emit
      if @emit
        @emit[ type, msg ]
      else
        @request_client.emit type, msg
      end
    end

    def error msg
      @error_count += 1
      emit :error, msg
      false
    end

    attr_reader :error_count

    def info msg
      emit :info, "# #{ msg }"
      nil
    end

    def payload data
      emit :payload, data
      nil
    end

    def pen
      @request_client.send :pen
    end

    def stylize *a
      pen.stylize(* a )
    end
  end



  module Color_InstanceMethods

    def color?
      @request_client.send :color?
    end
  end



  class CLI
    include SubClient_InstanceMethods          # *before* cli client mechanics
    extend Porcelain

    porcelain do
      emits :payload => :all
    end

    DRY_RUN = -> ctx do
      ctx[:dry_run] = nil unless ctx.key?( :dry_run ) # away soon
      on '-n', '--dry-run', "Dry run." do
        ctx[:dry_run] = true
      end
    end

    STASHES = ->(ctx) do
      ctx[:stashes_path] = '../Stashes'
      on '-s', '--stashes <dir>', "Where the stashed files live #{
        }(default: #{ ctx[:stashes_path] })." do |v|
        ctx[:stashes_path] = v
      end
    end

    VERBOSE = -> ctx do
      ctx[:verbose] = nil
      on '-v', '--verbose', 'verbose output' do
        ctx[:verbose] = true
      end
    end




    option_syntax do |ctx|
      separator " description: move all untracked files to another folder (usu. outside of the project.)"
      instance_exec ctx, &DRY_RUN # these away at [#007]
      instance_exec ctx, &STASHES
      instance_exec ctx, &VERBOSE
    end

    argument_syntax "<name>"

    def save name, opts
      api_invoke :save, opts.merge( stash_name: name )
    end



    option_syntax do |ctx|
      separator " description: lists the \"stashes\" (just a directory listing)."
      instance_exec ctx, &STASHES
    end

    def list opts
      api_invoke :list, opts
    end



    option_syntax do |ctx|
      separator " description: In the spirit of `git stash show`, reports on contents of stashes."
      ctx[:patch] = ctx[:stat] = nil # api requires all args to be present
      ctx[:color] = true
      on('--no-color', "No color.") { ctx[:color] = false }
      on('--stat', "Show diffstat format (default) (can be used with --patch).") { ctx[:stat] = true }
      on('-p', '-u', '--patch', "Generate patch (can be used with --stat).") { ctx[:patch] = true }
      instance_exec ctx, &STASHES
    end

    argument_syntax '<name>'

    def show name, opts
      api_invoke :show, opts.merge( name: name )
    end



    option_syntax do |ctx|
      separator " description: Attempts to put the files back if there are no collisions."
      instance_exec ctx, &DRY_RUN
      instance_exec ctx, &STASHES
      instance_exec ctx, &VERBOSE
    end

    argument_syntax '<name>'

    def pop name, opts
      api_invoke :pop, opts.merge( name: name )
    end



    option_syntax do |_|
      separator " description: Shows the files that would be stashed."
    end

    def status _
      o = API::Actions::Save.new self
      num = 0
      o.normalized_relative_others.each do |file_name|
        num += 1
        payload file_name
      end
      if 0 == num
        info "(no untracked files)"
      end
      true
    end

  protected

    def initialize _, stdout, stderr
      block_given? and fail 'sanity'
      _gsu_sub_client_init! nil
      super() do |o|
        o.on_payload { |e| stdout.puts e }
        o.on_info { |e| stderr.puts e }
        o.on_error { |e| stderr.puts e }
      end
    end

    def api_invoke mixed_action_name, param_h
      klass = API::Actions.const_fetch mixed_action_name
      # (induced above is: API::Actions::List, API::Actions::Save,
      # API::Actions::Show, API::Actions::Pop)
      o = klass.new self
      res = o.invoke param_h
      res
    end


    def emit type, msg
      runtime.emit type, msg
    end


    define_method :escape_path, & Headless::CLI::PathTools::FUN.pretty_path
    protected :escape_path


    pen = Headless::CLI::Pen::MINIMAL

    define_method( :pen ) { pen }

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
        res = set!( param_h ) or break
        res = execute
      end while nil
      res
    end

  protected

    # (initialize defined in sub-client i.m)

    fun = Headless::CLI::PathTools::FUN
    absolute_path_hack_rx = fun.absolute_path_hack_rx

    define_method :collection do
      @collection_cache ||= { }
      @collection_cache.fetch( stashes_path ) do |k|
        c = Collection.new self, stashes_path, -> type, str do # define emit as:
          use = str.gsub absolute_path_hack_rx do # scan for strings that look
            escape_path $~[0]                  # like paths and escape them
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
        res = @request_client.send :escape_path, x # otherwise, let the modality
      end                                      # client (e.g.) decide how
      res
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
        param_a = self.class.const_get :PARAMS, false
        missing_a = param_a - param_h.keys
        invalid_a = param_h.keys - param_a
        error = -> msg do
          self.error "can't invoke api action \"#{
            }#{ normalized_action_name.join ' ' }\" - #{ msg }"
        end
        if ! invalid_a.empty?
          error[ "invalid parameter(s): (#{ invalid_a.join ', ' })" ]
          break( res = false )
        end
        if ! missing_a.empty?
          error[ "missing required parameter(s): (#{ missing_a.join ', ' })" ]
          break( res = false )
        end
        param_h.each { |k, v| send "#{ k }=", v } # might trigger error()
        res = error_count == before            # (better to keep it strict)
      end while nil
      res
    end

    def verbose                             # if a given action doesn't support
      true                                  # this, we fallback to "loud" for
    end                                     # the above nerk
  end




  module API::Actions
    extend MetaHell::Boxxy        # (`const_fetch`)
  end



  class API::Actions::Save < API::Action

    PARAMS = [ :dry_run, :stash_name, :stashes_path, :verbose ]

    def execute
      info "(raw stashes path: #{ stashes_path })" if verbose
      Headless::CLI::PathTools.clear # see notes at `pretty_path` -- there is danger
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

    attr_accessor :dry_run, :stash_name, :stashes_path, :verbose

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



  class API::Actions::List < API::Action

    PARAMS = [:stashes_path]

  protected

    def execute
      collection.validate_existence or return false
      count = 0
      collection.each_stash do |stash|
        count += 1
        emit :payload, stash.name
      end
      count
    end

    # --*--

    attr_accessor :stashes_path

  end



  class API::Actions::Show < API::Action

    PARAMS = [:color, :name, :patch, :stashes_path, :stat]

    def execute
      s = collection.stash name
      @stash = collection.stash(name).validate_existence or return false
      (@patch.nil? and @stat.nil?) and @stat = true
      @stat and @stash.each_stat_line(&method(:emit))
      @patch and @stash.each_patch_line(&method(:emit))
      true
    end

  protected

    def initialize *a
      @patch = @stat = nil
      super
    end

    attr_accessor :color, :name, :patch, :stashes_path, :stat
    alias_method :color?, :color # api compat

  end



  class API::Actions::Pop < API::Action
    include Color_InstanceMethods

    PARAMS = [:dry_run, :name, :stashes_path, :verbose]

  protected

    def execute
      @stash = collection.stash(name).validate_existence or return false
      @stash.pop dry_run, verbose, method(:emit)
    end

    attr_accessor :dry_run, :name, :stashes_path, :verbose
  end


  # --*--

  class Collection
    include SubClient_InstanceMethods
    include Color_InstanceMethods

    def each_stash
      @pathname.children( false ).each do |child| # or e.g. Errno::ENOENT
        stash = self.stash child.to_s
        yield stash
      end
      nil
    end

    def stash name
      @cache[name] ||= Stash.new self, @pathname, name, @emit
    end

    def stash_valid_for_writing name
      stash = self.stash name
      if stash.valid_for_writing?
        stash
      else
        false
      end
    end

    def validate_existence
      res = nil
      if @pathname.exist?
        res = true
      else
        @emit[ :error, "Stashes dir does not exist: #{ @pathname }" ]
        res = false
      end
      res
    end

  protected

    def initialize request_client, stashes_path, emit
      _gsu_sub_client_init! request_client
      @cache = { }
      @emit = emit
      @pathname = ::Pathname.new stashes_path
    end
  end



  class Stash
    include GitStashUntracked::Services::FileUtils
    include SubClient_InstanceMethods
    include Color_InstanceMethods

    def each_patch_line &emit
      f = color? ? ColorizedPatch[ emit ] : emit
      MakePatch[ pathname, f ]
    end

    def each_stat_line &emit
      MakeStat[ self, pathname, emit ]
    end

    def name
      @pathname.basename.to_s
    end

    def pop dry_run, verbose, emit
      filenames = self.filenames.map { |f| ::Pathname.new f }
      # ( the below will need to change for [#005] )
      if (existed = filenames.select(&:exist?)).any?
        emit[:error, "Can't pop, destination file(s) exist:"]
        existed.each { |p| emit[:error, p.to_s] }
        return false
      end
      filenames.each do |path|
        path.dirname.directory? or mkdir_p(path.dirname, :verbose => true, :noop => dry_run)
        mv(pathname.join(path), path, :verbose => true, :noop => dry_run) # always verbose when popping
      end
      _prune dry_run, verbose
      true
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
        # will need to change for [#005] below
        res = move normalized_relative_file_name, dest.to_s, verbose: true, noop: dry_run
      end while nil
      res
    end

    # save below as-is for #posterity /slash/ you-know-what
    def validate_existence
      pathname.exist? and return self
      error "Stash does not exist: #{ name }"
    end

    def valid_for_writing?
      if @valid_for_writing.nil?
        validate_for_writing!
      end
      @valid_for_writing
    end

  protected

    def initialize request_client, dir_pathname, stash_name, emit
      _gsu_sub_client_init! request_client
      @color = nil
      @emit = emit
      @pathname = dir_pathname.join stash_name
      @quiet = { }
      @valid_for_writing = nil
    end

    def filenames
      ::Enumerator.new do |o|
        GitStashUntracked::Services::Open3.popen3("cd #{pathname}; find . -type f") do |_, sout, serr|
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

    attr_reader :pathname

    def _prune dry_run, verbose
      stack = []
      cmd = "find #{ @pathname } -type d"
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
        dir_pathname = @pathname.dirname
        if @pathname.exist?
          dir = ::Dir[ "#{ @pathname }/*" ]
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



  module MakePatch
    # singleton hack! (is a module only so the name shows up appropriately)
  end



  class << MakePatch
    include GitStashUntracked::Services::FileUtils

    def call path, emit
      ::File.directory?(path) or raise "not a directory: #{ path }"
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
    ->(type, line) do
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
