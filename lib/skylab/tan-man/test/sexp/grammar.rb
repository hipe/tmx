# encoding: UTF-8

require_relative 'test-support'

module Skylab::TanMan::TestSupport::Sexp


  class Grammar                   # this is ad-hoc whatever we need to add
                                  # to our test grammars to make them executable
                                  # on the command line, crucial for visual
                                  # testing and dev.  remember we want to stay
                                  # clear of aritrary application code porcelain


    include CONSTANTS

    extend Autoloader             # we need it now for next line
    extend self::ModuleMethods    # (autoloads the eponymous file here)

    extend MetaHell::Let

    # include Autoloader::Inflection::Methods
    include TanMan::Models::DotFile::Parser::InstanceMethods # err msg porcelain
    include TanMan::TestSupport::Tmpdir::InstanceMethods #prepared_tanman_tmpdir

    include Headless::CLI::Client::InstanceMethods # as a fun excercise anything
                                  # porcelain-y we end up needing below is a
                                  # goofy experiment and possibly an
                                  # abstraction candidate.

    def invoke argv               # enhance headless with invite at the end
      res = super
      if false == res
        usage_and_invite          # or alternately just emit :help, invite_line
        res = nil                 # for now we do this ourselves, it's [#hl-019]
      end
      res
    end


  protected

    pen = Headless::CLI::Pen::Minimal.new
    def pen.escape_path str
      "«#{ str }»"                # "guillemets" just for fun and practice
    end

    define_method :initialize do
      |sin=$stdin, sout=$stdout, serr=$stderr| # observe pattern [#sl-114]

      @stdin = sin                # we keep this stream on deck but don't set
                                  # upstream yet. it takes logix. [#hl-022]
      self.io_adapter = build_io_adapter nil, sout, serr, pen
      _headless_sub_client_init nil
    end



    #        ----*-  protected methods, alphabetical  -*----


    let :anchor_dir_pathname do
      self.class.grammars_module.dir_pathname.join stem_path
    end

    num_rx = /\A([A-Za-z]+(?:::[A-Za-z]+)+)\d+[^:]+\z/

    define_method :anchor_module_head do
      _md = num_rx.match(self.class.to_s) or fail("failed to infer#{
        } anchor_module_head from this class name, expecting leading consts#{
        } without digits and the trailing const to have a digit in it#{
        } (You may need to implement your own hacky thing up the chain.)#{
        } (Your thing: #{self.class})")
      _md[1]
    end


    pathspec_syntax = '[ - | <filename> ]'

    define_method :build_option_parser do
      op = ::OptionParser.new
      op.banner = usage_line
      op.separator "#{ em 'options:' }"

      op.on '-F', '--force', 'force overwrite of cached grammars (#dev)' do
        param_queue.push [:force_overwrite, true]
      end

      op.on '-s <string>', "parse string instead of #{ pathspec_syntax }" do |v|
        param_queue.push [:upstream_string, v]
      end

      op.on '-e <method>', "if the parse succeeds,",
        "run <method> on the result and dump this result." do |meth|
        param_queue.push [:eval_string, meth]
      end

      op.on '-v', '--verbose', 'hopefully turns on verbose parsing' do
        param_queue.push [:verbose_parsing, true]
      end
    end


    def default_action
      :execute
    end

    attr_accessor :eval_string    # used by param_queue

    def eval_string_run result
      unless /\A[a-z_]+[a-z0-9_]*\z/ =~ eval_string
        fail "must be a valid method name: #{eval_string.inspect}"
      end
      _ = result.send eval_string
      TanMan::TestSupport::Services::PP.pp _, io_adapter.errstream
      true
    end

    def execute
      info "(parsing upstream which is a #{ upstream.class })"
      info "(parser is #{ parser.class })"
      result = parse upstream
      info "OK, WE GOT (after #{ 1000 * parse_time_elapsed_seconds
        } ms): #{ result.class }"
      if result
        if eval_string
          eval_string_run result
        else
          TanMan::TestSupport::Services::PP.pp result, io_adapter.errstream
          true
        end
      end
    end

    attr_accessor :force_overwrite # in flux --
                                  # sometimes we want to blow away tmpdir once


    def grammars o
      o.treetop_grammar 'g1.treetop'
    end

    def load_parser_class
      f = on_load_parser_info ||
        -> e { info "      (loading parser ^_^ #{ gsub_path_hack e.to_s })" }

      TreetopTools::Parser::Load.new( self,
        -> o do
          force_overwrite and o.force_overwrite!
          o.generated_grammar_dir tmpdir_prepared
          o.root_for_relative_paths anchor_dir_pathname
          grammars o
        end,
        ->(o) do
          o.on_info(& f )
          o.on_error { |e| fail("failed to load grammar: #{e}") }
        end
      ).invoke
    end

    attr_reader :pathname

    define_method :resolve_upstream do   # #watch'ed by [#hl-022] for dry
      ok = false                  # [#hl-023] exit-code aware, [#019] invite
      begin
        if upstream
          if argv.empty?
            ok = true
          else
            error "Upstream already resolved. #{
              }Expecting zero args, had #{ argv.length }: #{argv.first.inspect}"
          end
        elsif 1 == argv.length
          path = argv.shift
          if '-' == path
            if @stdin.tty?
              error "expecting STDIN to be a readable stream, was tty."
            else
              self.upstream = build_stream_input_adapter @stdin
              @stdin = nil
              ok = true
            end
          elsif @stdin.tty?
            @pathname = ::Pathname.new path
            if @pathname.exist?
              self.upstream = build_file_input_adapter @pathname
              ok = true
            else
              error "file not found: #{ escape_path @pathname }"
            end
          else
            error "can't have both STDIN and <pathspec>: #{ path }"
          end
        else
          error "expecting #{ pathspec_syntax }, had #{ argv.length } args."
        end
      end while nil
      ok
    end

    let :stem_const_rx do
      /\A  #{ anchor_module_head }  (.+)  \z/x
    end

    fun = Autoloader::Inflection::FUN

    let :stem_path do
      fun.pathify[ stem_const_rx.match(self.class.to_s)[1] ]
    end

    def tmpdir_prepared
      @tmpdir_prepared ||= begin
        pn = prepared_tanman_tmpdir.join stem_path
        td = prepared_tanman_tmpdir.class.new pn
        if ! td.exist?
          td.prepare # because parent gets rewritten once per runtime
        end
        td
      end
    end

    def upstream
      io_adapter.instream
    end

    def upstream= x
      io_adapter.instream = x
    end

    define_method :usage_line do
      "#{ em 'usage:' } #{ program_name } [opts] #{ pathspec_syntax }"
    end

    def upstream_string= str
      if upstream
        error "can't set upstream string, upstream is already set - #{
          }#{ str.inspect }"
      else
        self.upstream = build_string_input_adapter str
      end
      str
    end

    def verbose_parsing= bool     # `verbose_parsing` as a concept is confined
      if bool                     # to this file for now!
        TanMan::Sexp::Auto.do_debug = true
      end
    end
  end
end
