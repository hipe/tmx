require 'set'

module Skylab::MyTree
  class API::Actions::Tree < API::Action

    param :pattern, reader: true

  protected

    def initialize request_client
      @affix_metadata = nil
      @file = nil
      @verbose = { }
      super
    end

    def affix_metadata! sym
      if @affix_metadata
        @affix_metadata.push( sym ).reverse!
        @affix_metadata.uniq!
        @affix_metadata.reverse!
        # unique elements in the freshest requested order
        # ( a b c b    ->  a c b )
      else
        @affix_metadata = [sym]
      end
    end

    raise = -> msg do
      e = MyTree::Services::OptionParser::InvalidArgument.exception
      e.reason = msg
      raise e
    end

    define_method :build_option_parser do
      o = MyTree::Services::OptionParser.new

      o.on '-f', '--file <file>', "instead of #{ pl :path },#{
        } get tree paths from file, one per line" do |x| # 80!
        if self[:file] and x != self[:file]
          raise[ "won't set #{ pl :file } to #{ he x }, already set as #{
            he file }" ]
        end
        self[:file] = x
      end

      o.on '-l', '--line-count', 'as repored by wc, affixed as metadata' do
        affix_metadata! :line_count
      end

      o.on '-n', '--dry-run', 'assorted meanings. do not use heh.' do
        self[:dry_run] = true
      end

      o.on '-m', '--mtime', 'if ordinary file, display humanized mtime' do
        affix_metadata! :mtime
      end

      o.on('-P <pattern>', 'meh') { |x| self[:pattern] = x }


      a = ['find command', 'lines']
      a_s = "[#{ a.map { |x| x[0] }.join '|' }]"
      hilite_first = ->( s ) { "#{ kbd s[0] }#{ s[1..-1] }" }

      o.on '-v', "--verbose #{ a_s }",
        "verbose #{ a.map{ |x| hilite_first[x] }.join ', ' } #{
        }(any permutation)" do |letters|
        if letters
          letters.split('').each do |s|
            found = a.detect { |word| s == word[0] }
            found or raise[ "expecting any of #{a_s}, not #{ s.inspect }" ]
            verbose[Inflection::FUN.methodify[ found ]] = true
          end
        else
          a.each { |word| verbose[Inflection::FUN.methodify[ word ]] = true }
        end
      end

      o.on('-h', '--help', 'me') { enqueue! :help }

      o.separator ''

      o.separator "  (it can also read paths from STDIN instead of #{
        }#{ pl :file } or #{ pl :path })"

      o.summary_indent = '  ' # two spaces, down from four (aesthetics, tests)

      o
    end

    attr_accessor :dry_run

    attr_reader :file

    fly = nil

    define_method :metadata_string do |line|
      if @affix_metadata
        fly ||= MyTree::Models::Node::Flyweight.new
        fly.set! line
        arr = @affix_metadata.reduce [] do |a, sym|
          x = API::Actions::Tree::Metadatas.const_fetch sym
          x.call( a, fly, self )
        end
        if ! arr.empty?
          "(#{ arr.join ', ' })"
        end
      end
    end

    attr_reader :paths

    def process *path
      self[:paths] = path
      e = resolve_lines
      e and render e
    end

    def render enum
      tree = API::Actions::Tree::Tree.new self, verbose
      enum.reduce( tree ) do |t, line|
        verbose[:lines] and emit :info, "(#{line})"
        t.puts line, metadata_string(line)
        t
      end
      tree.flush # tell it we are done!
      true
    end

    types = -> do
      h = ::Hash.new { |_, k| raise ::KeyError.new "key not found: #{k}" }
      s = ::Struct.new :symbol, :label
      o = ->( symbol, label ) { h[symbol] = s.new symbol, label }
      o[ :file, ->{ "#{ pl :file } (#{ he file })" } ]
      o[ :paths, ->{ "#{ pl :path } (#{ paths.map{ |p| he p }.join ', ' })" } ]
      o[ :instream, ->{ 'STDIN' } ]
      h
    end.call

    define_method :resolve_lines do
      set = ::Set.new
      set.add types[:file] if file
      set.add types[:instream] unless io_adapter.instream.tty?
      set.add types[:paths] unless paths.empty?
      set.add types[:paths] if set.empty?
      if 1 == set.length
        send "resolve_lines_from_#{ set.first.symbol }"
      else
        usage "ambiguous upstream: won't read from #{
          and_ set.map { |x| instance_exec(&  x.label) } }"
      end
    end

    def resolve_lines_from_file
      begin
        fh = ::File.open file
        ::Enumerator.new do |y|
          while s = fh.gets
            y << s.chomp
          end
          fh.close
        end
      rescue ::Errno::ENOENT => e
        usage "when opening #{ pl :file } : #{ e.message }"
      end
    end

    def resolve_lines_from_paths
      paths.empty? and paths.push '.'
      paths.map! { |p| ::Pathname.new p }
      find = API::Actions::Tree::Find::Command.new( self, paths, pattern )
      find.verbose = verbose ; find.dry_run = dry_run
      find.each
    end

    def resolve_lines_from_instream
      o = io_adapter.instream
      ::Enumerator.new do |y|
        while s = o.gets
          y << s.chomp
        end
      end
    end

    attr_reader :verbose

    # --*-- local abbreviations --*--

    alias_method :he, :human_escape

    alias_method :pl, :parameter_label

  end
end
