require_relative '../test-support'

module ::Skylab::TanMan::TestSupport::Sexp
  ::Skylab::TanMan::TestSupport[ Sexp_TestSupport = self ]

  module Grammars
    @dir_path = Sexp_TestSupport.dir_pathname.join('grammars').to_s # or orphan
    extend Sexp_TestSupport::Grammar::Boxxy
  end

  module ModuleMethods
    def using_grammar grammar_pathpart, *tags, &b
      context "using grammar #{grammar_pathpart}", *tags do
        let(:using_grammar_pathpart) { grammar_pathpart }
        module_eval( &b )
      end
    end
  end

  module InstanceMethods

    let :client do
      o = _parser_client_module.new upstream, paystream, infostream
      if do_debug_parser_loading
        # keep defaults i guess, for now
      else
        o.on_load_parser_info = ->(e) { }
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
      Sexp_TestSupport::Grammars
    end

    let :paystream do
      $stdout # yeah that's what i said #kiss
    end

    let :upstream do
      nil
    end
  end
end
