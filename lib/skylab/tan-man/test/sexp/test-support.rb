require_relative '../test-support'

module ::Skylab::TanMan::Sexp::TestSupport
  extend ::Skylab::MetaHell::Autoloader::Autovivifying::Recursive
  self.dir_path = dir_pathname.join('..').to_s # there is no test-support/ dir

  TestSupport = self

  module Grammars
    extend TestSupport::Grammar::Boxxy
    self.dir_path = dir_pathname.join('../../grammars').to_s # or make an orphan
  end

  def self.extended mod
    mod.extend ModuleMethods
    mod.send :include, InstanceMethods
  end

  module ModuleMethods
    include ::Skylab::TanMan::TestSupport::ModuleMethods

    def using_grammar grammar_pathpart, *tags, &b
      context "using grammar #{grammar_pathpart}", *tags do
        let(:using_grammar_pathpart) { grammar_pathpart }
        module_eval &b
      end
    end
  end

  module InstanceMethods
    extend ::Skylab::TanMan::TestSupport::InstanceMethodsModuleMethods
    include ::Skylab::TanMan::TestSupport::InstanceMethods

    let :client do
      o = _parser_client_module.new upstream, paystream, infostream
      if debug_parser_loading
        # keep defaults i guess, for now
      else
        o.on_load_parser_info_f = ->(e) { }
      end
      o
    end

    let :infostream do
      $stderr # #kiss
    end

    let :_input_fixtures_dir_path do
      _parser_client_module.fixtures_dir_path
    end

    -> do
      rx = /\A(?<num>\d+(?:-\d+)*)(?:-(?<rest>.+))?\z/

      let :_parser_client_constant do
        md = rx.match(using_grammar_pathpart) or fail("expecting #{
          } to start with numbers: \"#{using_grammar_pathpart}\"")
        "Grammar#{ md[:num].gsub '-', '_' }#{ "_#{ constantize md[:rest] }" if
          md[:rest] }".intern
      end
    end.call

    let :_parser_client_module do
      _parser_clients_module.const_get _parser_client_constant, false
    end

    let :_parser_clients_module do
      ::Skylab::TanMan::Sexp::TestSupport::Grammars
    end

    let :paystream do
      $stdout # yeah that's what i said #kiss
    end

    let :upstream do
      nil
    end
  end
end
