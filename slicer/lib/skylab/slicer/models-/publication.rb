module Skylab::Slicer

  module Models_::Publication

    Actions = ::Module.new

    class Actions::Publish < Action_

      @is_promoted = true

      @instance_description_proc = -> y do
        y << '(no where close to integrated)'
      end

      if false

        # <- 4

# EDIT: this is super ancient and just here for amusement #todo
require 'fileutils'
require 'optparse'
require 'json'
require 'open3'
require 'stringio'
require 'time'

module TmxGit
  PUSH_THRESHOLD_SECONDS = 24 * 60 * 60
  ARROW_GLYPH = '- '

  module Colors
    extend self
    def bold str ; style str, :bright, :green end
    def hi   str ; style str, :green          end
    def ohno str ; style str, :red            end
    def yelo str ; style str, :yellow         end
    Styles = { :bright => 1, :red => 31, :yellow => 33, :green => 32, :cyan => 36 }
    Esc = "\e"  # "\u001b" ok in 1.9.2
    def style str, *styles
      nums = styles.map{ |o| o.kind_of?(Integer) ? o : Styles[o] }.compact
      "#{Esc}[#{nums.join(';')}m#{str}#{Esc}[0m"
    end
  end
  module TimeHelper
    PER = u = {}
    u[:minute] = 60 ; u[:hour] = 60 * u[:minute] ; u[:day] = 24 * u[:hour]
    u[:week] = 7 * u[:day] ; u[:year] = 52 * u[:week]
    UNITS = [:year, :week, :day, :hour, :minute]
    class << self
      def natural seconds
        sec_i = seconds.to_i
        unit = any = nil
        UNITS.each do |u|
          if 0 < (any = sec_i / PER[u])
            unit = u
            break
          end
        end
        unit or return "#{seconds} seconds"
        ss = ["#{any} #{unit}#{s any}"]
        about = nil
        if unit != UNITS.last
          _unit = UNITS[UNITS.index(unit) + 1]
          _rem = sec_i % PER[unit]
          _any = _rem / PER[_unit]
          _rem % PER[_unit] > 0 and about = "about "
          _any > 0 and ss.push "#{_any} #{_unit}#{s _any}"
        end
        "#{about}#{ss.join(' ')}"
      end
      def s int
        1 == int ? '' : 's'
      end
    end
  end
  module Open2
    def open2 cmd, opts = {}
      filter = prefix = nil
      if opts[:prefix]
        prefix = opts[:prefix]
        filter = lambda do |str|
          str.gsub!(/(?<=\n)(?=.)/, prefix) # newlines followed by something, put it in between
        end
      end
      streams = {
        :out => { :buffer => StringIO.new, :stream => ui.out, :trailing => false, :during => false },
        :err => { :buffer => StringIO.new, :stream => ui.err, :trailing => false, :during => false }
      }
      Open3.popen3(cmd) do |sin, sout, serr|
        streams[:out][:in] = sout
        streams[:err][:in] = serr
        open = [:out, :err]
        loop do
          open.each_with_index do |sym, idx|
            o = streams[sym]
            if IO.select([o[:in]], nil, nil, 0.1) # yes this could instead do .. etc
              closed = false
              begin
                str = o[:in].readpartial(4096)
                o[:in].closed? and closed = true
                if str && ! str.empty?
                  if prefix
                    filter[use_string = str.dup]
                    o[:during] ||= (o[:trailing] = true) # output prefix at beginning of output always
                    o[:trailing] and use_string = "#{prefix}#{use_string}"
                    o[:trailing] = /\n\z/ =~ str # careful
                  else
                    use_string = string
                  end
                  o[:stream].write(use_string)
                  o[:buffer].write(str)
                end
              rescue ::EOFError
                closed = true
              end
              if closed
                open[idx] = nil
                open.compact!
              end
            end
          end
          open.empty? and break
        end
      end
      streams[:out][:buffer].rewind
      streams[:err][:buffer].rewind
      [streams[:out][:buffer].read, streams[:err][:buffer].read]
    end
  end
end
module TmxGit
  Default_UI = ::Struct.new( :out, :err ).new ::STDOUT, ::STDERR
  module Push
    class InvalidRequestError < RuntimeError; end
    class CLI
      include Colors
      attr_reader :ui
      def program_name
        File.basename $PROGRAM_NAME
      end
      def usage_line
        "#{hi 'usage:'} #{program_name} [opts] <git@host.com> [<repo-dir> [<repo-dir> [..]]]"
      end
      def invite_line
        "Try #{hi "#{program_name} -h"} for help."
      end
      def run argv
        argv = argv.dup
        req = {}
        @ui = ui = Default_UI
        op = OptionParser.new do |o|
          o.banner = <<-HERE.gsub(/^ {12}/, '')
            #{hi 'description:'} Pushes many git repos at once (possibly for use in replication).
            #{usage_line}
            #{hi 'arguments:'}
              <git@whohah.com>        The remote git repository base url to push to
            #{hi 'options:'}
          HERE
          o.on('-h', '--help', 'This screen.') { ui.err.puts(o.to_s); exit(0) }
          o.on('-f', '--failed', 'Only try ones that failed before (implies --retry).') do
            req[:failed] = true; req[:retry] = true
          end
          o.on('-r', '--retry', 'Retry ones that failed before.') { req[:retry] = true }
          o.on('-n', '--dry-run', 'Dry run.') { req[:dry_run] = true }
          req[:push_threshold_seconds] = PUSH_THRESHOLD_SECONDS
          o.on('-t', '--threshold <SECONDS>',
            "How long do we wait after a successful push to try and push again?",
            "(default: #{TimeHelper.natural req[:push_threshold_seconds]})"
          )
          o.on('-u', '--update', 'Update manifest with any new repository folders found.') { req[:update] = true }
          o.on('-l', '--list', 'Print a list to stdout of the dirs and exit.') { req[:list] = true }
          o.on('-L', "like --list but the opposite (show dirs that are not repos).") { req[:list] = req[:list_reverse] = true }
          o.on('-v', '--verbose', 'Be verbose.') { req[:verbose] = true }
          o.on('--all', "pass through this option to git-push (push all branches)") { req[:all] = true }
          o.on('--prune-attr ATTR', '(internal use!)') do |v|
            req[:_prune] ||= []
            req[:_prune].push v
          end
        end
        begin
          op.parse!(argv)
          argv.empty? and ! req[:list] and
            raise OptionParser::ParseError.new("missing required argument: <git@host.org>")
          req[:host] = argv.shift
          req[:paths] = argv.empty? ? ['.'] : argv
        rescue OptionParser::ParseError => e
          return invite_help(e)
        end
        begin
          API.new(ui, req).push
        rescue InvalidRequestError => e
          return invite_help(e)
        end
        true
      end
      def invite_help e
        ui.err.puts e.to_s
        ui.err.puts usage_line
        ui.err.puts invite_line
        false
      end
    end
    class API
      include Colors
      def initialize *a
        @ui, @req = a
      end
      attr_reader :req, :ui
      def push
        init_manifest or return false
        cnt = 0
        reps = @manifest.repositories
        _ = reps.length
        reps = _filter(reps)
        req[:list] and return _list(reps)
        _ == reps.length or of_all = " (of #{_} total)"
        _info "looking at #{reps.length} repos#{of_all} to push.."
        reps.each do |repo|
          cnt += 1
          ui.err.puts "#{hi repo.id} (#{cnt}/#{reps.length}):"
          repo.push
        end
        _show_summary
        _info "Done looking at or pushing #{cnt} repos."
        true
      end
    private
      def init_manifest
        dir = @req[:paths].first
        File.directory?(dir) or dir = File.dirname(dir)
        File.directory?(dir) or return _err("not a directory, can't make manifest: #{dir}")
        ok = nil
        begin
          @manifest =
          if File.exist?(p = File.join(dir, Manifest::BASENAME))
            m = Manifest.reconstitute p, ui, @req
            @req[:update] and m.update
            m
          else
            Manifest.create p, ui, @req
          end
          ok = true
        rescue Manifest::RuntimeError => e
          _err e
          ok = false
        end
        ok
      end
      def _list reps
        these = reps.map{ |r| r.path.gsub(%r{\A\./}, '') }
        req[:list_reverse] and
          these = Dir[File.join(@manifest.repos_dir, '/*')].map{ |p| p.gsub(%r{\A\./}, '') } - these
        ui.out.puts these
        true
      end
      def _filter reps
        whitelist = []
        whitelist << lambda do |repo|
          repo.skip? or return true
          @manifest.report(repo.path, :skipped) and false
        end
        req[:failed] and whitelist << lambda do |repo|
          repo.last_push_attempt_succeeded? or return true
          @manifest.report(repo.path, :skipped_because_succeeded) and false
        end
        reps.select do |repo|
          ! whitelist.detect { |l| ! l.call(repo) }
        end
      end
      def _show_summary
        sync_report_data = @manifest.sync_report_data
        ks = sync_report_data.keys.map(&:to_s).sort.map(&:to_sym)
        ks.each do |k|
          _s = k.to_s.gsub UNDERSCORE_, SPACE_
          _info "summary: #{ _s }: (#{ sync_report_data[k].join( ', ' ) })"
        end
      end
      def _err msg
        ui.err.puts "#{me}: #{ohno('error:')} #{msg}"
        false
      end
      def _info msg
        ui.err.puts "#{hi me}: #{msg}"
      end
      def me
        'git push'
      end
    end
    module SyncReport
      def report path, status_symbol
        sync_report_data[status_symbol].push path
        true
      end
      def sync_report_data
        @sync_report_data ||= Hash.new { |h, k| h[k] = [] }
      end
    end
    class Manifest
      include SyncReport
      include Colors
      BASENAME = 'manifest.json.list'
      class RuntimeError < ::RuntimeError; end
      class << self
        def reconstitute path, ui, req
          @path = path
          man = new(:ui => ui, :req => req, :path => path)
          repositories = []
          File.open(path, 'r') do |fh|
           @lineno = 0
            while line = fh.gets
              @lineno += 1
              repo = Repo.new(:manifest => man)
              repo.req = req
              repo.update_attributes _json_parse(line)
              repositories.push repo
            end
          end
          man.repositories = repositories
          man
        end
        def _json_parse line
          begin
            JSON.parse(line)
          rescue JSON::ParserError => e
            raise RuntimeError.new(<<-HERE.gsub(/\n  */, ' ').strip
              Failed to parse manifest.  Each line of manifest must be valid json.
              Invalid json found on line #{@lineno} of #{@path}.  Edit by hand
              to correct this if you can: character #{e.to_s.strip}
              HERE
              )
          end
        end
        def create path, ui, req
          man = new(:ui => ui, :req => req, :path => path)
          man._create
          man
        end
      end
      def initialize hash = {}
        hash = hash.dup
        u = hash.delete(:ui) and self.ui = u
        r = hash.delete(:req) and self.req = r
        hash.each { |k, v| send("#{k}=", v) }
      end
      attr_reader   :path
      attr_accessor :records
      attr_accessor :repositories
      attr_accessor :repos_dir
      attr_accessor :req
      attr_accessor :ui
      def _create
        repositories = find_repository_directories
        repositories.sort!
        repositories.empty? and _fail("No repositories ending in '*.git' found in #{repos_dir}!")
        self.repositories = repositories.map { |path| Repo.new(:path => path, :manifest => self) }
        write_new_file
        nil
      end
      def update
        had = repositories.map(&:path)
        have = find_repository_directories
        new = have - had
        old = had - have
        new.empty? and _info("found no new repositories to add.")
        old.any? and _warn("has repos that were not found on disk: (#{old.join(', ')})")
        if new.any?
          _info("#{yelo 'adding:'} (#{new.join(', ')}) to manifest.")
          repositories.concat new.map { |p| Repo.new(:path => p, :manifest => self) }
          repositories.sort_by!(&:path)
          write_new_file true
        end
        [old.size, new.size]
      end
      def find_repository_directories
        find_bare_repository_directories + find_non_bare_repository_directories
      end
      def find_bare_repository_directories
        Dir[File.join(repos_dir, '*.git')]
      end
      def find_non_bare_repository_directories
        Dir[File.join(repos_dir, '*')].select do |path|
          File.directory?(File.join(path, '.git'))
        end
      end
      def path= path
        @repos_dir ||= File.dirname(path)
        @path = path
      end
      def update_record id, json_string
        json_string.include?("\n") and
          _fail("Fow now this ghetto format can't take newlines in json strings: #{json_string}")
        str = "\"id\":#{id.to_json}"
        finder = /#{Regexp.escape(str)}/
        first_half_lines = []
        second_half_lines = []
        old_line = nil
        File.open(path, 'r') do |fh|
          while line = fh.gets and finder !~ line do
            first_half_lines.push line.strip
          end
          if finder =~ line
            old_line = line
          else
            _fail("line not found with regex: #{finder}")
          end
          while line = fh.gets do
            second_half_lines.push line.strip
          end
        end
        all_lines = first_half_lines + [json_string] + second_half_lines
        all_content = all_lines.join("\n")
        ret = nil

        _mode = ::File::WRONLY | ::File::TRUNC | ::File::CREAT

        File.open(path, _mode) { |fh| ret = fh.write(all_content) }

        req[:verbose] and _report_updated(id, old_line, json_string)
        ret
      end
      def _report_updated id, old_line, json_string
        old = JSON.parse(old_line)
        now = JSON.parse(json_string)
        l = old.keys - now.keys
        r = now.keys - old.keys
        c = old.keys & now.keys
        a = [
          ("(elements removed: (#{_derp old, l}))" if l.any?),
          ("(elements added: (#{_derp now, r})" if r.any?)
        ].compact
        if c.any?
          _c = c.select { |k| old[k] != now[k] }
          if _c.any?
            s = _c.map { |k| "#{k.inspect} changed from #{old[k].inspect} to #{now[k].inspect}" }
            a.push "(#{s.join(', ')})"
          end
        end
        a.empty? and a.push("(no change)")
        _info "updated #{id} #{a.join(' ')}."
        nil
      end
      def _derp h, ks
        ks.map{ |k| "#{k.inspect} : #{h[k].inspect}" }.join(', ')
      end
      def write_new_file clobber=false
        if File.exist?(path) and ! clobber
          _fail("won't clobber existing file: #{path}")
        end
        lines = []
        safety_check = {}
        repositories.each do |repo|
          if safety_check.key?(repo.id)
            _fail("multiple keys found: #{repo.id}")
          else
            safety_check[repo.id] = true
          end
          lines.push repo.to_json
        end
        bytes = 0
        File.open(path, clobber ? WRITE_MODE_ : 'a+' ) do |fh|
          lines.each do |line|
            bytes += line.size
            fh.puts line
          end
        end
        _info "Wrote #{path} (#{bytes} bytes)"
        true
      end
      def _fail msg
        raise self.class::RuntimeError.new(msg)
      end
      def _warn msg
        ui.err.puts "#{prefix}#{yelo 'warning:'} #{msg}"
      end
      def _info msg
        ui.err.puts "#{prefix}#{msg}"
      end
      def prefix
        'manifest '
      end
    end
    class Repo
      include Colors, Open2
      ATTRS = {
        :id =>             { :stored => true }, # KEEP FIRST
        :branches =>       { :stored => true },
        :last_push_attempt_at => { :stored => true },
        :last_push_attempt_succeeded => { :stored => true },
        :path =>           { :stored => false },
        :skip =>           { :stored => true }
      }
      def initialize hash
        update_attributes hash
      end
      attr_accessor :branches
      attr_reader :id
      attr_reader :last_push_attempt_at
      attr_accessor :last_push_attempt_succeeded
      alias_method :last_push_attempt_succeeded?, :last_push_attempt_succeeded
      attr_reader :path
      attr_writer :req
      attr_accessor :skip
      alias_method :skip?, :skip
      def update_attributes hash
        hash = hash.dup
        manifest = hash.delete(:manifest)
        manifest and self.manifest = manifest
        pruned = []
        hash.each do |k, v|
          if ATTRS.key?(k.intern)
            send("#{k}=", v)
          elsif req && req[:_prune] && req[:_prune].include?(k.to_s)
            pruned.push k
          else
            _fail("invalid name: #{k.inspect} (you could --prune-attr it if you are careful!)")
          end
        end
        if pruned.any?
          _info "pruned: (#{pruned.join(', ')}) from #{id}"
          journal
        end
        true
      end
      def path= path
        @id = File.basename(path)
        @path = path
      end
      def id= id
        if manifest?
          @path = File.join(manifest.repos_dir, id)
        end
        @id = id
      end
      def last_push_attempt_at= mixed_time
        case mixed_time
        when String
          t = Time.parse(mixed_time) # will raise arg. error on bad parse
          @last_push_attempt_at = t
        when Time
          @last_push_attempt_at = mixed_time
        else
          raise ArgumentError.new("need string here")
        end
        mixed_time
      end
      def to_json
        hash = {}
        ATTRS.each do |k, v|
          v[:stored] or next
          unless (v = self.send(k)).nil?
            hash[k] = v
          end
        end
        hash.to_json
      end
      def push
        resp = { :push => false }
        if skip
          _info "Skipping (\"skip\":true)."
        elsif req[:failed] && last_push_attempt_succeeded
          _info "Skipping (last attempt succeeded)."
        elsif last_push_attempt_at.nil?
          _info "No record of ever having pushed, pushing."
          resp[:push] = true
        elsif (t = Time.now - last_push_attempt_at) > push_threshold_seconds
          _info "Pushed #{_time t} ago.  Pushing again."
          resp[:push] = true
        elsif last_push_attempt_succeeded
          _info "Successfully pushed #{_time t} ago, skipping"
        elsif req[:retry]
          _info "Failed #{_time t} ago, retrying."
          resp[:push] = true
        else
          _info "Failed #{_time t} ago, skipping (\"retry\":false)."
        end
        resp[:push] and _push
        resp
      end
      def push_threshold_seconds
        req[:push_threshold_seconds] || PUSH_THRESHOLD_SECONDS
      end
      def _push
        (host = req[:host]) or _invalid("can't push without a host")
        url = "#{ host }:#{ id }"
        push_branches = _which_branches_to_push or return false
        push_branches.each { |b| _push_branch b, url }
      end
      def exists?
        _check_repo_exists false
      end
      def _check_repo_exists verbose=true
        case true
        when File.directory?(path)
          true # we could do more but meh
        when File.exist?(path)
          if verbose
            _warn("is not a folder, skipping.")
            manifest.report(path, :not_a_folder)
          end
          false
        else
          if verbose
            _warn("does not exist, skipping.")
            manifest.report(path, :not_found)
          end
          false
        end
      end
      def _push_branch push_branch, url
        _check_repo_exists or return
        opts = nil
        if :all == push_branch
          push_branch = nil
          opts = '--all'
        end
        cmd = "cd #{path} ; git push #{opts} #{url} #{push_branch}"
        _info cmd
        if req[:dry_run]
          _info "(dry run, skipped)"
          # journal
        else
          out, err = open2(cmd, :prefix => '  > ')
          self.last_push_attempt_at = Time.now
          if "" != out
            self.last_push_attempt_succeeded = false
            _report(:out => out, :err => err, :cmd => cmd)
            journal
          elsif 0 == err.index(url) or 0 == err.index('To ') # fuu
            self.last_push_attempt_succeeded = true
            manifest.report(path, :successfully_pushed)
            journal
          elsif 0 == err.index("Everything up-to-date")
            self.last_push_attempt_succeeded = true
            manifest.report(path, :everything_up_to_date)
            journal
          else
            _report(:out => out, :err => err, :cmd => cmd) or
              _notice("Don't know what to do about the above.  Skipping.")
            self.last_push_attempt_succeeded = false
            # do not journal (save) it for now, easier for development
          end
        end
      end
      def _report info
        out = info[:out] ; err = info[:err]
        if ! (out.nil? || out.empty?)
          case out
          when /non-fast-forward updates were rejected/
            manifest.report(path, :non_fast_forward_updates_were_rejected)
          else
            manifest.report(path, :unknown_issue) # @todo
          end
        elsif ! (err.nil? || err.empty?)
          case err
          when /^W access for [^ ]+ DENIED/
            manifest.report(path, :write_access_denied)
          else
            manifest.report(path, :unknown_issue) # @todo
          end
        end
      end
      MASTER = ['master']
      def _which_branches_to_push
        _check_repo_exists or return false
        @branches.kind_of?(Array) and return @branches
        list = `cd #{path} ; git branch`.strip.split("\n")
        list.map! { |s| s.strip.gsub(/^\* /, '') }
        '*' == @branches and return list
        if req[:all]
          list.length == 1 and return list
          return [:all]
        end
        MASTER == list and return list
        if list.empty?
          _notice 'No branches! Skipping.'
          manifest.report(path, :no_branches)
        else
          _notice "Please indicate branches to sync among: (#{list.join(', ')}).  Skipping."
          manifest.report(path, :choose_branches)
        end
        false
      end
      def _notice msg
        _info "#{yelo 'notice'}: #{msg}"
        false
      end
      def _warn msg
        _info "#{ohno 'warning:'} #{msg}"
        false
      end
      def _info msg
        ui.err.puts "  #{ARROW_GLYPH}#{msg}"
      end
      def _time t
        TimeHelper.natural t
      end
      def journal &block
        manifest? or _fail("cannot journal a block without a manifest defined.")
        block and instance_eval(&block)
        manifest.update_record id, to_json
      end
      def manifest= manifest
        class << self; self end.send(:define_method, :manifest) { manifest }
        manifest
      end
      def manifest?
        respond_to?(:manifest)
      end
      def ui
        manifest.ui
      end
      def req
        manifest.req
      end
      def _fail msg
        raise Manifest::RuntimeError.new(msg)
      end
      def _invalid msg
        raise Push::InvalidRequestError.new("#{self.class}: #{msg}")
      end
    end
  end
end

# -> 4
      end
    end
  end
end
