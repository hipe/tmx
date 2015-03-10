
# read [#bn-005], this is a similar arrangement, tl;dr: for tmx integration

if ! defined? ::Skylab::Yacc2Treetop
  load ::File.expand_path( '../../../../bin/tmx-yacc2treetop', __FILE__ )
  # when running all of the specs, we won't know if tmx ran before our own test
end

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
