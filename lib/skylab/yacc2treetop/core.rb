
# ( just like its sister, this is explained in [#bn-005] )

require_relative 'load'

module Skylab::Yacc_2_Treetop
  module CLI
    module Client
      ::Skylab::TMX::Front_Loader::One_shot_adapter_[ self,
        -> program_name, sin, sout, serr, argv do
          cli = ::Skylab::Yacc2Treetop::CLI.new sout, serr
          cli.program_name = program_name
          cli.run argv
        end ]
    end
  end
end
