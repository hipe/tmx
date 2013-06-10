#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Namespace::Via_Mod_Func

  #   ~ we made this to get cull working again pro-actively after [#037] ~

  ::Skylab::Face::TestSupport::CLI::Namespace[ This_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module Sandbox
  end

  CONSTANTS::Sandbox = Sandbox

  Face = Face

  module Wizzle
    module CLI
      class Client < Face::CLI
        namespace :'data-source', -> { Actions::DataSrc }, aliases: [ 'ds' ]
      end
      module Actions
        class DataSrc < Face::Namespace
        end
      end
    end
  end

  do_invoke = Do_invoke_[]

  describe "#{ Face::CLI }::Namespace via mode func" do

    extend This_TestSupport

    as :usg1, /\Ausage: wtvr \{data-source\} \[opts\] \[args\]\z/, :styled
    as :usg2, /\A  +wtvr \{-h \[cmd\]}/, :nonstyled
    as :opt1, /\Aoption:\z/, :styled
    as :opt2, /\A  +-h, --help \[cmd\]  +this screen \[or sub-command help\]\z/, :nonstyled
    as :cmd1, /\Acommand:\z/, :styled
    as :cmd2, /\A  +data-source  +usage: wtvr data-source \[-h \[cmd\]\] \[\.\.\]\z/, :styled
    as :inv1, /\ATry wtvr -h <sub-cmd> for help on a particular command\.\z/, :styled

    context "some context" do

      let :client_class do Wizzle::CLI::Client end

      it "wat." do
        x = invoke '-h'
        expect %i| usg1 usg2 opt1 opt2 cmd1 cmd2 inv1 |
        x.should eql( nil )
      end

      it "how." do
        x = invoke 'ds'
        expect :exp, :inv0
        x.should eql( nil )
      end
    end

    as :exp, /\AExpecting nothing\.\z/, :nonstyled
    as :inv0, /\Atry wtvr data-source -h \[sub-cmd\] for help\.\z/i, :styled

  end

  if do_invoke  # try executing this file directly, passing '-x'
    Wizzle::CLI::Client.new( nil, SO_, SE_ ).invoke( ::ARGV )
  end
end
