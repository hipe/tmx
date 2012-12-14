#!/usr/bin/env ruby -w

require 'fileutils'
require 'open3'
require File.expand_path('../../lib/skylab', __FILE__)
require 'skylab/porcelain/all'
require 'skylab/face/core' # pretty_path


module Skylab::GitStashUntracked

  Face = ::Skylab::Face

  class Porcelain
    extend ::Skylab::Porcelain

    porcelain do
      emits :payload => :all
    end

    DRY_RUN = ->(ctx) { on('-n', '--dry-run', "Dry run.") { ctx[:dry_run] = true } }
    STASHES = ->(ctx) do
      ctx[:stashes] = '../Stashes'
      on('-s', '--stashes <dir>', "Where the stashed files live (default: #{ctx[:stashes]}).") { |v| ctx[:stashes] = v }
    end



    option_syntax do |ctx|
      separator " description: move all untracked files to another folder (usu. outside of the project.)"
      instance_exec ctx, &DRY_RUN
      instance_exec ctx, &STASHES
    end

    argument_syntax "<name>"

    def save name, opts
      Plumbing::Save.new(runtime, opts.merge(:name => name)).invoke
    end



    option_syntax do |ctx|
      separator " description: lists the \"stashes\" (just a directory listing)."
      instance_exec ctx, &STASHES
    end

    def list opts
      Plumbing::List.new(runtime, opts).invoke
    end



    option_syntax do |ctx|
      separator " description: In the spirit of `git stash show`, reports on contents of stashes."
      ctx[:color] = true
      on('--no-color', "No color.") { ctx[:color] = false }
      on('--stat', "Show diffstat format (default) (can be used with --patch).") { ctx[:stat] = true }
      on('-p', '-u', '--patch', "Generate patch (can be used with --stat).") { ctx[:patch] = true }
      instance_exec ctx, &STASHES
    end

    argument_syntax '<name>'

    def show name, opts
      Plumbing::Show.new(runtime, opts.merge(:name => name)).invoke
    end



    option_syntax do |ctx|
      separator " description: Attempts to put the files back if there are no collisions."
      instance_exec ctx, &DRY_RUN
      instance_exec ctx, &STASHES
    end

    argument_syntax '<name>'

    def pop name, opts
      Plumbing::Pop.new(runtime, opts.merge(:name => name)).invoke
    end



    option_syntax do |_|
      separator " description: Shows the files that would be stashed."
    end

    def status _
      o = Plumbing::Save.new runtime
      num = o.each_file do |fn|
        runtime.emit :payload, fn
      end
      if 0 == num
        runtime.emit :info, "# (no untracked files)"
      end
      true
    end
  end



  class Plumbing

    # (nothing public yet)

  protected

    def initialize runtime, params_h=nil
      runtime or fail "sanity - where is runtime?"
      @runtime = runtime
      @dry_run = false
      if params_h
         params_h.each { |k, v| send "#{ k }=", v }
      end
    end

                                               # the Collection is (i think)
                                               # the rootmost data object.
    fun = Headless::CLI::PathTools::FUN                 # We ofc. want to pass absoulte
    absolute_path_hack_rx = fun.absolute_path_hack_rx # pathnames to the
                                               # ::FileUtils functions but
    define_method :collection do               # when they display in the CLI
      Collection.cache[stashes] ||= begin      # modality we want them to be
        emit = -> type, str do                 # pretty.  This hack scans
          use = str.gsub absolute_path_hack_rx do # messages looking for strings
            escape_path $~[0]                  # that look like abs. paths
          end                                  # and allows the root modality
          self.emit type, use                  # client to prettify them
        end                                    # possibly substituting ~ and '.'
        c = Collection.new stashes, dry_run: dry_run, &emit # where appropriate.
        c                                      # if you think this is ugly
      end                                      # now you should have seen it
    end                                        # before ^_^

    attr_accessor :dry_run


    # What we want to do is delegate this call up to the modality client to
    # allow its own custom version of the method but we can't do that now
    # because of how borked and unusable all.rb is..

    define_method :escape_path, & Headless::CLI::PathTools::FUN.pretty_path

    def emit type, payload
      @runtime.emit type, payload
    end

    def error msg
      emit :error, msg
      false
    end

    def failed msg
      emit :error, "failed: #{ msg }"
      false
    end

    def info msg
      emit :info, msg
      nil
    end

    attr_accessor :name

    def popen3 cmd, &block
      ::Open3.popen3 cmd, &block
    end

    attr_accessor :stashes
  end


  class Plumbing::Save < Plumbing

    def invoke
      Headless::CLI::PathTools.clear # see notes at `pretty_path` -- there is danger
      result = nil
      begin
        stash = collection.stash(name).validate_for_writing
        if ! stash
          result = stash
          break
        end
        any = false
        each_file do |file|
          stash.stash_file file
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

    command = 'git ls-files -o --exclude-standard'

    define_method :each_file do |&path|
      result = 0
      info "# #{ command }"
      popen3 command do |_, sout, serr|
        loop do
          e = serr.read
          if '' != e
            error e
            result = false
            break
          end
          line = sout.gets
          line or break
          result += 1
          path[ line.strip ]
        end
      end
      result
    end
  end



  class Plumbing::List < Plumbing
    def invoke
      collection.validate_existence or return false
      count = 0
      collection.each_stash do |stash|
        count += 1
        emit :payload, stash.name
      end
      count
    end
  end



  class Plumbing::Show < Plumbing

    def invoke
      @stash = collection.stash(name).validate_existence or return false
      (@patch.nil? and @stat.nil?) and @stat = true
      @color.nil? or @stash.color = color
      @stat and @stash.each_stat_line(&method(:emit))
      @patch and @stash.each_patch_line(&method(:emit))
      true
    end

  protected

    def initialize *a, &b
      @patch = @stat = nil
      super
    end

    attr_accessor :color

    attr_accessor :format

    attr_accessor :patch

    attr_accessor :stat

  end



  class Plumbing::Pop < Plumbing
    def invoke
      @stash = collection.stash(name).validate_existence or return false
      @stash.pop(&method(:emit))
    end
  end



  class Collection

    @cache = { } # (accessor defined after this scope)

    def each_stash
      @path.exist? or raise "no such directory: #{ @path }"
      ::Dir.new( @path.to_s ).each do |name|
        name[0,1] == '.' and next
        yield stash(name)
      end
      nil
    end

    def stash name
      @cache[name] ||= Stash.new @path, name, @opts, &@emit
    end

    def validate_existence
      @path.exist? and return true
      @emit[:error, "Stashes dir does not exist: #{@path}"]
      false
    end

  protected

    def initialize path, opts, &block
      @cache = {}
      @emit = block
      @opts = opts
      @path = ::Pathname.new path
    end
  end



  class << Collection

    attr_reader :cache

  end



  class Stash
    include ::FileUtils

  public

    attr_accessor :color

    def each_patch_line &emit
      f = @color ? ColorizedPatch[ emit ] : emit
      PatchMaker.call pathname, & f
    end

    def each_stat_line &emit
      StatMaker.call pathname, color: @color, &emit
    end

    attr_reader :name

    def pop &emit
      filenames = self.filenames.map { |f| ::Pathname.new f }
      if (existed = filenames.select(&:exist?)).any?
        emit[:error, "Can't pop, destination file(s) exist:"]
        existed.each { |p| emit[:error, p.to_s] }
        return false
      end
      filenames.each do |path|
        path.dirname.directory? or mkdir_p(path.dirname, :verbose => true, :noop => @dry_run)
        mv(pathname.join(path), path, :verbose => true, :noop => @dry_run) # always verbose when popping
      end
      @dry_run or _prune
      true
    end

    # save below as-is for #posterity /slash/ you-know-what
    def validate_existence
      pathname.exist? and return self
      failed "Stash does not exist: #{ name }"
    end

    def validate_for_writing
      @valid = valid = nil
      begin
        if pathname.exist?
          dir = ::Dir[ "#{ pathname }/*" ]
          if dir.any?
            failed "Destination dir must be empty (\"stash\" already exists?).#{
              } Found files:\n#{ dir.join "\n" }"
            valid = false
          else
            valid = true          # empty dirs are valid for writing, sure
          end
        elsif dirpathname.exist?  # parent path must exist
          valid = true            # the child dir needs to be made, but not yet
        else
          failed "Stashes directory must exist: #{ dirpathname }"
          valid = false
        end
      end while nil
      @valid = valid
      result = valid ? self : valid
      result
    end

  protected

    def initialize dirpathname, stash_name, opts, &emit
      @color = true
      @dry_run = false
      @valid = false
      @dirpathname = dirpathname
      @emit = emit
      @quiet = { }
      @name = stash_name.to_s
      opts.each { |k, v| send("#{k}=", v) }
    end

    attr_accessor :dry_run

    def failed msg
      @emit[:error, msg.to_s]
      false
    end

    def filenames
      ::Enumerator.new do |o|
        ::Open3.popen3("cd #{pathname}; find . -type f") do |_, sout, serr|
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

    define_method :stash_file do |file|
      result = nil
      begin
        if ! ( @valid || validate_for_writing )
          result = false
          break
        end
        dest = pathname.join file
        if ! dest.dirname.exist?
          @quiet.fetch dest.dirname.to_s do |normalized|
            mkdir_p dest.to_s, verbose: true, noop: dry_run
            @quiet[normalized] = true
          end
        end
        result = move file, dest.to_s, verbose: true, noop: dry_run
      end while nil
      result
    end

    def pathname
      @pathname ||= @dirpathname.join @name
    end

    def _prune
      stack = []
      ::Open3.popen3("find #{pathname} -type d") do |_, sout, serr|
        while s = sout.gets do stack.push(s.strip) end
      end
      while s = stack.pop
        rmdir(s, :verbose => true)
      end
    end

    attr_reader :dirpathname

  end



  module PatchMaker
    # singleton_methods only ack!
  end



  class << PatchMaker
    include ::FileUtils

    def call path, &emit
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
        ::Open3.popen3('find . -type f') do |_, sout, serr|
          '' != (s = serr.read) and raise("nope: #{s}")
          while s = sout.gets do each_path[s.strip] end
        end
      end
    end
  end

  extend ::Skylab::Porcelain::Styles

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



  class StatMaker
    include ::Skylab::Porcelain::Styles

  public

    def run
      _render _calculate
    end

  protected

    def initialize path, opts, &emit
      @color = true
      @emit = emit
      @path = path
      opts.each { |k, v| send("#{k}=", v) }
    end

    def _calculate
      filecount = Struct.new :name, :insertions, :deletions, :combined
      files = []
      PatchMaker.call @path do |type, line|
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

    attr_accessor :color

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
        if @color
          '' == pluses  or pluses = stylize(pluses, :green)
          '' == minuses or minuses = stylize(minuses, :red)
        end
        @emit[:payload, (format % [f.name, f.combined, "#{pluses}#{minuses}"])]
      end
      @emit[:payload, ("%s files changed, %d insertions(+), %d deletions(-)" % [files.count, total_inserts, total_deletes])]
    end
  end



  class << StatMaker
    def call path, opts, &emit
      StatMaker.new(path, opts, &emit).run
    end
  end
end

# in some cases write a ruby script at ~/bin/g-s-u that simply loads this file
if File.basename(__FILE__) == File.basename($PROGRAM_NAME)
  ::Skylab::GitStashUntracked::Porcelain.new{ |o| o.on_all { |e| $stderr.puts e } }.invoke(ARGV)
end
