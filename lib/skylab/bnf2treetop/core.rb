
#                     ~ [#bn-005] explains it all ~

if ! defined? ::Skylab::TMX
  require_relative '../tmx/core'
end

if ! defined? ::Skylab::Bnf2Treetop
  load ::File.expand_path( '../../../../bin/tmx-bnf2treetop', __FILE__ )
  # we won't know if the tmx specs run before our own do
end


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
