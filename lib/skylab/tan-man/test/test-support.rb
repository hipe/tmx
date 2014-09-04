require_relative '../core'
require 'skylab/test-support/core'

module Skylab::TanMan::TestSupport

  ::Skylab::TestSupport::Regret[ self ]

  TanMan_ = ::Skylab::TanMan

  module TestLib_

    memoize = -> p { p_ = -> { x = p[] ; p_ = -> { x } ; x } ; -> { p_[] } }

    sidesys = TanMan_::Autoloader_.build_require_sidesystem_proc

    Build_tmpdir_via_stem = -> s do
      _path_s = Dev_tmpdir_pathname[].join( s ).to_path
      Tmpdir[].new _path_s
    end

    CLI_client = -> x do
      HL__[]::CLI::Client[ x ]
    end

    CLI_pen_minimal = -> do
      HL__[]::CLI::Pen::Minimal.new
    end

    Class_creator_module_methods_module = -> mod do
      mod.include MetaHell__[]::Class::Creator::ModuleMethods ; nil
    end

    Debug_IO = -> do
      HL__[]::System::IO.some_stderr_IO
    end

    Dev_client = -> do
      HL__[]::DEV::Client.new
    end

    Dev_tmpdir_pathname = -> do
      HL__[]::System.defaults.dev_tmpdir_pathname
    end

    File_utils = memoize[ -> do
      require 'fileutils' ; ::FileUtils
    end ]

    FU_client = -> do
      HL__[]::IO::FU
    end

    HL__ = sidesys[ :Headless ]

    IO_adapter_spy = -> do
      HL__[]::TestSupport::IO_Adapter_Spy
    end

    JSON = memoize[ -> do
      require 'json' ; ::JSON
    end ]

    Let = -> mod do
      mod.extend MetaHell__[]::Let
    end

    MetaHell__ = sidesys[ :MetaHell ]

    PP = memoize[ -> do
      require 'pp' ; ::PP
    end ]

    Shellwords = memoize[ -> do
      require 'shellwords' ; ::Shellwords
    end ]

    Three_IOs = -> do
      HL__[]::System::IO.some_three_IOs
    end

    Tmpdir = -> do
      TS__[]::Tmpdir
    end

    TS__ = sidesys[ :TestSupport ]

    Unstyle_proc = -> do
      HL__[]::CLI::Pen::FUN.unstyle
    end

    Unstyle_styled = -> s do
      HL__[]::CLI::Pen::FUN.unstyle_styled[ s ]
    end
  end

  module CONSTANTS
    TanMan_ = TanMan_
    TestLib_ = TestLib_
    TestSupport  = ::Skylab::TestSupport
    TMPDIR_STEM  = 'tan-man'
    TMPDIR = TestLib_::Build_tmpdir_via_stem[ TMPDIR_STEM ]
  end

  include CONSTANTS # for use here, below

  TMPDIR = TMPDIR  # #annoy

  # this is dodgy but should be ok as long as you accept that:
  # 1) you are assuming meta-attributes work and 2) the below is universe-wide!
  # 3) the below presents holes that need to be tested manually
  if false
  -> o do
    o.local_conf_dirname = 'local-conf.d' # a more visible name
    o.local_conf_maxdepth = 1
    o.local_conf_startpath = -> { TMPDIR }
    o.global_conf_path = -> { TMPDIR.join 'global-conf-file' }
  end.call TanMan_::API
  end

  module ModuleMethods

    def input str
      let(:input_string_to_use) { str }
      let(:input_path_stem_to_use) { }
    end

    def using_input input_path_stem, *tags, &b
      context "using input #{ input_path_stem }", *tags do
        let( :input_path_stem_to_use ) { input_path_stem }
        let( :input_string_to_use ) { }
        module_eval(& b)
      end
    end

    def using_input_string str, *tags, &b
      desc = tags.shift if ::String === tags.first
      desc ||= "using input string #{str.inspect}"
      context(desc, *tags) do
        let(:input_path_stem_to_use) { }
        let(:input_string_to_use) { str }
        module_eval(&b)
      end
    end

    TestLib_::Class_creator_module_methods_module[ self ]
  end


  module Tmpdir

    o = { }

    get = nil

    prepare = -> do               # always re-create the tmpdir (blows the
      TMPDIR.prepare              # old one and its contents away!).
      get = -> { TMPDIR }         # Also memoize it into `get`
      TMPDIR
    end

    get = -> do                   # get the last prepared tmpdir during the
      prepare[ ]                  # lifetime of this ruby process, re-creating
    end                           # it (preparing it) iff prepare was never yet
                                  # called.
    o[:prepare] = prepare

    o[:get] = -> { get[] }

    FUN = ::Struct.new(* o.keys).new ; o.each { |k, v| FUN[k] = v } ; FUN.freeze

  end


  module Tmpdir::InstanceMethods

    fun = Tmpdir::FUN

    define_method :prepare_tanman_tmpdir do |patch=nil|
      tmpdir = fun.prepare[ ]
      if patch
         tmpdir.patch patch
      end
      tmpdir # important
    end

    define_method :prepared_tanman_tmpdir, & fun.get

    def tanman_tmpdir
      TMPDIR # less screaming in tests is good
    end
  end


  module CONSTANTS
    Tmpdir = Tmpdir
  end


  module InstanceMethods

    include Tmpdir::InstanceMethods

    def clear_api_if_necessary
      if ! api_was_cleared
        @api_was_cleared = true
        TanMan_::Services.services.api.clear_all_services
      end
      nil
    end

    attr_reader :api_was_cleared

    def _build_normalized_input_pathname stem
      __input_fixtures_dir_pathname.join stem
    end

    let :api do
      api = TanMan_::Services.services.api
      if do_debug
        TanMan_::API.debug!
      end
      api
    end

    def client
      client ||= build_client
    end

    def build_client
      client = TestLib_::Dev_client[].new
      o = TanMan_::TestSupport::ParserProxy.new client
      o.verbose = -> { do_debug }
      if do_debug_parser_loading
        o.profile = true
      else
        o.on_load_parser_info = ->(e) { }
        o.profile = false
      end
      o
    end

    def debug!                                 # (aliased to tanman_debug!)
      self.do_debug = true
      self.do_debug_parser_loading = true
    end
    alias_method :tanman_debug!, :debug!

    attr_accessor :do_debug

    def some_debug_stream
      TestSupport::System.stderr
    end

    attr_accessor :do_debug_parser_loading

    let :__input_fixtures_dir_pathname do
      ::Pathname.new _input_fixtures_dir_pathname
    end

    def input_path
      normalized_input_pathname.to_s
    end

    def input_pathname
      normalized_input_pathname
    end

    def input_string
      normalized_input_string
    end

    -> do
      f = nil
      define_method( :_my_before_all ) { f.call }
      f = -> do
        Tmpdir::FUN.get[ ]
        f = -> { }
      end
    end.call

    let :normalized_input_pathname do
      if input_path_stem_to_use
        _build_normalized_input_pathname input_path_stem_to_use
      end
    end

    let :normalized_input_string do
      if input_string_to_use
        if normalized_input_pathname
          fail('sanity - should not have both')
        else
          input_string_to_use
        end
      elsif normalized_input_pathname
        normalized_input_pathname.read
      else
        fail('sanity - should not have neither')
      end
    end

    let :output do
      o = TestSupport::IO::Spy::Group.new
      o.do_debug_proc = -> { do_debug }
      o.line_filter! TestLib_::Unstyle_proc[]
      o
    end

    def prepare_local_conf_dir
      tmpdir = prepare_tanman_tmpdir
      tmpdir.mkdir TanMan_::API.local_conf_dirname
      tmpdir # important
    end

    let :result do
      if normalized_input_pathname
        if input_string_to_use
          fail 'sanity - we have both'
        else
          client.parse_file normalized_input_pathname.to_s
        end
      elsif input_string_to_use
        client.parse_string input_string_to_use
      else
        fail 'sanity - we have neither'
      end
    end
  end
end
