require_relative '../../core'
require 'skylab/test-support/core'

::Skylab::TanMan::Sexp && nil # load

module ::Skylab::TanMan::Sexp::TestSupport
  extend ::Skylab::MetaHell::Autoloader::Autovivifying

  # look for constants under Sexp::TestSupport under test/sexp/ for now #strain
  self.dir_path = ::File.expand_path('..', __FILE__)

  self::Sexp = ::Skylab::TanMan::Sexp #strain
  self::TanMan = ::Skylab::TanMan
  def self.extended mod
    mod.module_eval do
      extend ModuleMethods
      include InstanceMethods
    end
  end
  module ModuleMethods
    def grammars_module
      Sexp::TestSupport::Grammars
    end
    def grammars_module_f= f
      singleton_class.send(:define_method, :grammars_module, &f)
    end
    def using_input input_path_stem, *tags, &b
      context("using input #{input_path_stem}", *tags) do
        let(:input_path_stem) { input_path_stem }
        let(:input_string) { input_pathname.read }
        module_eval(&b)
      end
    end
    def using_input_string str, *tags, &b
      desc = tags.shift if ::String === tags.first
      desc ||= "using input string #{str.inspect}"
      context(desc, *tags) do
        let(:input_string) { str }
        let(:result) do
          client.parse_string input_string
        end
        module_eval(&b)
      end
    end
    PATHPART_RX = /\A(?<num>\d+(?:-\d+)*)(?:-(?<rest>.+))?\z/
    def using_grammar grammar_pathpart, *tags, &b
      context("using grammar #{grammar_pathpart}", *tags) do
        grammars = grammars_module
        pn = grammars.dir_pathname.join grammar_pathpart
        let(:input_pathname) { pn.join("fixtures/#{input_path_stem}") }
        let(:client) do
          # hack to allow more complex names like "60-content-pattern"
          md = PATHPART_RX.match(grammar_pathpart) or fail("expecting #{
            }grammar_pathpart to stat with numbers: \"#{grammar_pathpart}\"")
          const = ["Grammar#{md[:num].gsub('-', '_')}",
            ("_#{ constantize md[:rest] }" if md[:rest]) ].join('').intern
          grammars.constants.include?(const) or
            load pn.join('client').to_s
          client = grammars.const_get(const).new(nil, $stdin, $stderr)
          initialize_client client
          client
        end
        module_eval(&b)
      end
    end
  end
  module InstanceMethods
    include ::Skylab::Autoloader::Inflection::Methods # constantize (sib. mod.)
    def initialize_client client # redefine with your own customizations
    end
    def input_path
      input_pathname.to_s
    end
    def result # #ack
      __memoized.fetch(:result) do |k|
        __memoized[k] = client.parse_file(input_path)
      end
    end
  end
end
