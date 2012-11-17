require_relative '../core' # assume tanman core loaded skylab.rb
require 'skylab/porcelain/core'
require 'skylab/test-support/core'

module Skylab::TanMan::TestSupport
  ::Skylab::TestSupport::Regret[ self ]

  MetaHell     = ::Skylab::MetaHell
  TanMan       = ::Skylab::TanMan


  TMPDIR_STEM  = 'tan-man'
  TMPDIR = ::Skylab::TestSupport::Tmpdir.new(
    ::Skylab::TMPDIR_PATHNAME.join(TMPDIR_STEM).to_s)


  # this is dodgy but should be ok as long as you accept that:
  # 1) you are assuming meta-attributes work and 2) the below is universe-wide!
  # 3) the below presents holes that need to be tested manually
  ->(o) do
    o.local_conf_dirname = 'local-conf.d' # a more visible name
    o.local_conf_maxdepth = 1
    o.local_conf_startpath = ->(){ TMPDIR }
    o.global_conf_path = ->() { TMPDIR.join('global-conf-file') }
  end.call TanMan::API


  module ModuleMethods

    def input str
      let(:input_string_to_use) { str }
      let(:input_path_stem_to_use) { }
    end

    def using_input input_path_stem, *tags, &b
      context("using input #{input_path_stem}", *tags) do
        let(:input_path_stem_to_use) { input_path_stem }
        let(:input_string_to_use) { }
        module_eval(&b)
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
  end

  module Tmpdir_InstanceMethods
    -> do
      execute_f = -> { TMPDIR.prepare }
      get_f = ->{ _memo = execute_f.call ; (get_f = ->{ _memo }).call }

      define_method :prepare_submodule_tmpdir do
        execute_f.call
      end
      define_method :prepared_submodule_tmpdir do
        get_f.call
      end
    end.call
  end


  class Generic
    class << self
      public :define_method
    end
  end


  module InstanceMethods
    include ::Skylab::Autoloader::Inflection::Methods
    include TanMan::API::Achtung::SubClient::ModuleMethods # headless_runtime

    def _build_normalized_input_pathname stem
      __input_fixtures_dir_pathname.join stem
    end

    let :client do
      io_adapter = Generic.new
      debug_parser_loading_f = -> { debug_parser_loading }
      io_adapter.singleton_class.define_method :emit do |type, payload|
        if debug_parser_loading_f.call
          $stderr.puts("      (zeep: #{payload} (#{type}))")
        elsif :info == type
          # ok to just totally ignore
        else
          fail("ok we probably want StreamsSpy here.")
        end
      end
      rt = headless_runtime io_adapter
      o = TanMan::TestSupport::ParserProxy.new rt
      o.dir_path = _parser_dir_path
      if debug_parser_loading
        o.profile = true
      else
        o.on_load_parser_info_f = ->(e) { }
        o.profile = false
      end
      o
    end

    def debug_parser_loading
      false # save to try it!
    end

    let :__input_fixtures_dir_pathname do
      ::Pathname.new _input_fixtures_dir_path
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
      define_method(:_my_before_all) { f.call }
      f = -> do
        prepared_submodule_tmpdir
        f = ->{ }
      end
      extend Tmpdir_InstanceMethods
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


if defined? ::RSpec # egads sorry -- for running CLI visual testing clients
  require_relative 'for-rspec' # egads sorry - visual test hack
end
