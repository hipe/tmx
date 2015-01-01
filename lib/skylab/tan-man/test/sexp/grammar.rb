# encoding: UTF-8

self._THIS_FILE_HAS_BEEN_ # .. furloughed but is kept for possible future use

require_relative 'test-support'

module Skylab::TanMan::TestSupport::Sexp


  class Grammar                   # this is ad-hoc whatever we need to add
                                  # to our test grammars to make them executable
                                  # on the command line, crucial for visual
                                  # testing and dev.  remember we want to stay
                                  # clear of arbitrary application code porcelain

    extend module ModuleMethods

      TestLib_::Let[ self ]

      let :fixtures_dir_pathname do
        dir_pathname.join('../fixtures').to_s
      end

      let :grammars_module do
        ::Skylab::TanMan.lib_.module_lib.expand_path_via_module '..', self
      end

      self
    end

    include TanMan_::Models_::DotFile::Parser::InstanceMethods  # err msg porcelain
    include TanMan_::TestSupport::Tmpdir::InstanceMethods  # prepared_tanman_tmpdir

    TestLib_::CLI_lib[].client self

    def initialize sin, * two_IO  # :+[#sl-114]
      two_IO.length.upto( 1 ) do |d|
        two_IO[ d ] = IO_at_index__[ d + 1 ]
      end

      @stdin = sin

      self.io_adapter = build_IO_adapter nil, * two_IO, Pen__[]

      super()
    end

    IO_at_index__ = -> do
      a = nil
      -> d do
        a ||= TestLib_::Three_IOs[]
        a[ d ]
      end
    end.call

    Pen__ = -> do
      p = -> do
        pen = TestLib_::CLI_lib[].pen.minimal_class.new
        def pen.pth str
          "«#{ str }»"  # :+#guillemets just for fun and practice
        end
        p = -> { pen } ; pen
      end
      -> { p[] }
    end.call

    attr_accessor :do_force_overwrite

    attr_accessor :receive_parser_loading_info_p


    def invoke argv               # enhance headless with invite at the end
      res = super
      if false == res
        usage_and_invite          # or alternately just emit :help, invite_line
        res = nil                 # for now we do this ourselves, it's [#hl-019]
      end
      res
    end

  private

    #        ----*-  private methods, alphabetical  -*----

    TestLib_::Let[ self ]

    let :anchor_dir_pathname do
      self.class.grammars_module.dir_pathname.join stem_path
    end

    num_rx = /\A([A-Za-z]+(?:::[A-Za-z]+)+)\d+[^:]+\z/

    define_method :anchor_module_head do
      md = num_rx.match self.class.name
      md or fail say_failed_amh
      md[ 1 ]
    end

    def say_failed_amh
      "failed to infer#{
        } anchor_module_head from this class name, expecting leading consts#{
        } without digits and the trailing const to have a digit in it#{
        } (You may need to implement your own hacky thing up the chain.)#{
        } (Your thing: #{ self.class })"
    end

    pathspec_syntax = '[ - | <filename> ]'

    define_method :build_option_parser do
      op = ::OptionParser.new
      op.banner = usage_line
      op.separator "#{ em 'options:' }"

      op.on '-F', '--force', 'force overwrite of cached grammars (#dev)' do
        param_queue.push [ :do_force_overwrite, true ]
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


    def default_action_i  # #hook-out [hl]
      :execute
    end

    def eval_string_run result
      unless /\A[a-z_]+[a-z0-9_]*\z/ =~ eval_string
        fail "must be a valid method name: #{eval_string.inspect}"
      end
      _ = result.send eval_string
      TestLib_::PP[].pp _, io_adapter.errstream
      true
    end

    def execute
      send_info_string "(parsing upstream which is a #{ upstream.class })"
      send_info_string "(parser is #{ parser.class })"
      result = parse upstream
      send_info_string "OK, WE GOT (after #{ 1000 * parse_time_elapsed_seconds
        } ms): #{ result.class }"
      if result
        if eval_string
          eval_string_run result
        else
          TestLib_::PP[].pp result, io_adatper.errstream
          true
        end
      end
    end

    def grammars o
      o.treetop_grammar 'g1.treetop'
    end

    def produce_parser_class

      info_p = receive_parser_loading_info_p
      info_p ||= -> s do
        receive_info_string "      (loading parser ^_^ #{ s })"  # was gsub_path_hack
      end

      TanMan_.lib_.TTT::Parser::Load.new( self,
        -> o do
          do_force_overwrite and o.force_overwrite!
          o.generated_grammar_dir tmpdir_prepared
          o.root_for_relative_paths anchor_dir_pathname
          grammars o
        end,
        ->(o) do
          o.on_info info_p
          o.on_error method :fail
        end
      ).invoke
    end

    def receive_info_string s
      @IO_adapter.errstream.puts s ; nil
    end

    define_method :resovle_upstream do
      fail 'YES'  #  :+[#hl-022]:read:#todo IFF this is ever used
      ok = false                  # [#hl-023] exit-code aware, [#019] invite
      begin
        if upstream
          if argv.empty?
            ok = true
          else
            send_error_string "Upstream already resolved. #{
              }Expecting zero args, had #{ argv.length }: #{argv.first.inspect}"
          end
        elsif 1 == argv.length
          path = argv.shift
          if '-' == path
            if @stdin.tty?
              send_error_string "expecting STDIN to be a readable stream, was tty."
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
              send_error_string "file not found: #{ pth @pathname }"
            end
          else
            send_error_string "can't have both STDIN and <pathspec>: #{ path }"
          end
        else
          send_error_string "expecting #{ pathspec_syntax }, had #{ argv.length } args."
        end
      end while nil
      ok
    end

    let :stem_path do
      _stem_const_rx = /\A  #{ anchor_module_head }  (.+)  \z/x
      _md = _stem_const_rx.match self.class.name
      _s = _md[ 1 ]
      TanMan_::Callback_::Name.lib.pathify[ _s ]
    end

    def tmpdir_prepared
      @tmpdir_prepared ||= bld_tmpdir_prepared
    end

    def bld_tmpdir_prepared
      pn = prepared_tanman_tmpdir.join stem_path
      td = prepared_tanman_tmpdir.class.new pn
      if ! td.exist?
        td.prepare  # because parent gets rewritten once per runtime
      end
      td
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
        send_error_string "can't set upstream string, upstream is already set - #{
          }#{ str.inspect }"
      else
        self.upstream = build_string_input_adapter str
      end
      str
    end

    def verbose_parsing= bool     # `verbose_parsing` as a concept is confined
      if bool                     # to this file for now!
        TanMan_::Sexp::Auto.do_debug = true
      end
    end
  end
end
