module Skylab::MyTree

  class API::Actions::Tree < API::Action

  private

    def initialize request_client
      super
      @do_verbose_find_command = @do_verbose_lines = @file_pattern = nil
      @metadata_ref_a = @paths_file = nil
      @verbose_a = [ 'find command', 'lines' ]
      @verbose_s = "[#{ @verbose_a.map { |s| s[0] } * '|' }]"
      @verbose_h = { }
    end

    #         ~ salient parts of option and arg parsing ~

    def build_option_parser

      o = MyTree::Services::OptionParser.new

      o.on '-f', '--file <file>', "instead of #{ par :path },#{
          } get tree paths from file, one per line" do |x|
        self.paths_file = x
      end

      o.on '-l', '--line-count', 'as repored by wc, affixed as metadata' do
        add_metadata :line_count
      end

      o.on '-m', '--mtime', 'if ordinary file, display humanized mtime' do
        add_metadata :mtime
      end

      o.on('-P <pattern>', 'meh') { |x| @file_pattern = x }

      -> do

        hilite = -> s { "#{ kbd s[0] }#{ s[1..-1] }" }

        o.on '-v', "--verbose #{ @verbose_s }",
          "verbose #{ @verbose_a.map(& hilite ) * ', ' } #{
              }(any permutation)" do |chars|
          set_verbose chars
        end

      end.call

      o.on '-h', '--help', 'me' do enqueue :help end

      o.separator ''

      o.separator "  (it can also read paths from STDIN instead of #{
        }#{ par :file } or #{ par :path })"

      o.summary_indent = '  ' # two spaces, down from four (aesthetics, tests)

      o
    end

    def process *path  # name is cosmetic!
      @path_a = path  # logic necessitates that this could possibly be zero len
      begin
        res = resolve_lines or break
        res = render res
      end while nil
      res
    end

    #         ~ complicated setters for options ~

    def add_metadata sym
      if @metadata_ref_a
        @metadata_ref_a.push( sym ).reverse!
        @metadata_ref_a.uniq!
        @metadata_ref_a.reverse!
        # unique elements in the freshest requested order
        # ( a b c b    ->  a c b )
      else
        @metadata_ref_a = [ sym ]
      end
      nil
    end

    def paths_file= x
      if @paths_file && x != @paths_file
        raise_op_invalid_argument_error "won't set #{ par :file } to #{
          }#{ hum x }, already set as #{ hum @paths_file }"
      else
        @paths_file = x
      end
    end

    methodize = ::Skylab::Autoloader::FUN.methodize

    define_method :set_verbose do |chars|
      bads = nil
      if chars
        use_symbols = chars.split( '' ).reduce( [] ) do |m, s|
          found = @verbose_a.detect { |word| s == word[0] }
          if found
            m << methodize[ found ]
          else
            ( bads ||= [] ) << s
          end
          m
        end
      else
        use_symbols = @verbose_a.map(& methodize ) - [ :lines ]
        # `do_verbose_lines` is too verbose to have it be a default
      end
      if bads
        raise_op_invalid_argument_error "expecting any of #{ @verbose_s }, #{
          }not #{ bads.map(& method( :ick ) ) * ', ' }"
      else
        use_symbols.each do |sym|
          send "do_verbose_#{ sym }=", true
        end
      end
    end

    #         ~ support for complicated setters for option parsing ~

    def raise_op_invalid_argument_error msg
      e = MyTree::Services::OptionParser::InvalidArgument.new
      e.reason = msg
      raise e
    end

    #         ~ local abbreviations ~

    alias_method :hum, :human_escape

    alias_method :par, :parameter_label

    #         ~ resolve the lines enumerator ~

    type_h = {
      file: -> { "#{ par :file } (#{ hum @paths_file })" },
      paths: -> { "#{ par :path } (#{ @path_a.map(& method( :hum ) ) * ', '})"},
      instream: -> { 'STDIN' }
    }

    define_method :resolve_lines do  # (this kind of thing tracked by [#hl-022])
      set = MyTree::Services::Set.new
      set << :file if @paths_file
      set << :paths if @path_a.length.nonzero?
      set << :instream if ! io_adapter.instream.tty?
      if set.length.zero?
        @path_a << '.'  # careful
        set << :paths
      end
      if 1 == set.length
        send :"resolve_lines_from_#{ set.first }"
      else
        usage_and_invite "ambiguous upstream: won't read from #{
          and_ set.map { |k| instance_exec(& type_h.fetch( k ) ) } }"
      end
    end

    def resolve_lines_from_file
      begin
        fh = ::File.open @paths_file
        ::Enumerator.new do |y|
          while s = fh.gets
            y << s.chomp
          end
          fh.close
          nil
        end
      rescue ::Errno::ENOENT => e
        usage_and_invite "when opening #{ par :file } : #{ e.message }"
      end
    end

    def resolve_lines_from_instream
      o = io_adapter.instream
      ::Enumerator.new do |y|
        while s = o.gets
          y << s.chomp
        end
        nil
      end
    end

    def resolve_lines_from_paths  # assume @path_a length is nonzero
      find = MyTree::Services::Find.new( method :error )
      find.concat_paths @path_a
      find.pattern = @file_pattern  # nil ok
      if @do_verbose_find_command
        info find.string if find.is_valid
      end
      find.each
    end

    #         ~ moneyshot ~

    fly = nil

    define_method :render do |enum|
      tree = API::Actions::Tree::Tree.new self, @do_verbose_lines
      metadata = if @metadata_ref_a
        fly ||= MyTree::Models::Node::Flyweight.new
        method :metadata_string
      else
        -> _ { }
      end
      enum.reduce tree do |t, line|
        info "(#{ line })" if @do_verbose_lines
        t.puts line, metadata[ line ]
        t
      end
      tree.flush # tell it we are done!
      true
    end

    define_method :metadata_string do |line|
      fly.set! line
      arr = @metadata_ref_a.reduce [] do |a, sym|
        API::Actions::Tree::Metadatas.const_fetch( sym )[ a, fly, self ]
      end
      if arr.length.nonzero?
        "(#{ arr * ', ' })"
      end
    end
  end
end
