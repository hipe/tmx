require_relative '../test-support'

module Skylab::TanMan::TestSupport::Sexp

  ::Skylab::TanMan::TestSupport[ TS_ = self ]

  include CONSTANTS

  TanMan_ = TanMan_
  TestLib_ = TestLib_

  module ModuleMethods

    def using_grammar grammar_pathpart, *tags, & p

      context "using grammar #{ grammar_pathpart }", *tags do

        define_method :using_grammar_pathpart do
          grammar_pathpart
        end

        module_exec( & p )
      end
    end
  end

  module InstanceMethods

    alias_method :sexp_original_client, :client

    let :client do
      client = parser_client_module.new upstream, paystream, infostream
      if do_debug_parser_loading  # :+#dbg
        # keep defaults i guess, for now
      else
        client.receive_parser_loading_info_p = -> s do
          if do_debug
            infostream.puts s
          end
        end
      end
      client
    end

    def infostream
      TestLib_::Debug_IO[]
    end

    def input_fixtures_dir_pathname
      parser_client_module.fixtures_dir_pathname
    end

    let :parser_client_constant do
      md = PCC_RX__.match using_grammar_pathpart
      md or fail say_pcc
      _id = md[ :num ].gsub '-', '_'
      if md[ :rest ]
        _end = "_#{ TestLib_::Constantize[ md[:rest] ] }"
      end
      :"Grammar#{ _id }#{ _end }"
    end

    PCC_RX__ = /\A(?<num>\d+(?:-\d+)*)(?:-(?<rest>.+))?\z/

    def say_pcc
      "expected this to start with numbers - \"#{ using_grammar_pathpart }\""
    end

    def parser_client_module
      _mod = parser_clients_module
      _i = parser_client_constant
      _mod.const_get _i, false
    end

    def parser_clients_module
      TS_::Grammars
    end

    let :paystream do
      $stdout # yeah that's what i said #kiss
    end

    let :upstream do
      nil
    end
  end

  GRAMMAR_MODULE_CONST_MISSING_METHOD_ = -> const_i do

    # ad-hoc one-off for loading our grammars on-demandj

    md = RX__.match const_i
    num, rest = md.captures
    a = [ num ]
    if rest
      a.push TanMan_::Callback_::Name.lib.pathify[ rest ]
    end
    _stem = a * '-'
    pn = dir_pathname.join "#{ _stem }/client"

    load pn.to_path

    const_defined? const_i, false or
      raise ::NameError, "where is #{ self }::#{ const_i }?"
    mod = const_get const_i, false
    mod.instance_variable_set :@dir_pathname, pn
    mod
  end

  RX__ = /\AGrammar(?<num>[0-9]+)(?:_(?<rest>.+))?\z/


  module Grammars  # [#023]

    define_singleton_method :const_missing, GRAMMAR_MODULE_CONST_MISSING_METHOD_

    TanMan_::Autoloader_[ self ]

  end
end
