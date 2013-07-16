
#                     ~ [#bn-005] explains it all ~

require_relative 'load'

module Skylab::BNF_2_Treetop
  module CLI
    module Client
      ::Skylab::TMX::Front_Loader::One_shot_adapter_[ self,
        -> program_name, i, o, e, argv do
          cli = ::Skylab::Bnf2Treetop::CLI.new o, e
          cli.program_name = program_name
          cli.invoke argv
        end ]
    end
  end
end
