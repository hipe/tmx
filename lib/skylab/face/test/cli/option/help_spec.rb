#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Option::Help

  ::Skylab::Face::TestSupport::CLI::Option[ This_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module Sandbox
  end

  CONSTANTS::Sandbox = Sandbox

  Face = Face

  module Beffer
    class CLI_Client < Face::CLI
      use :hi

      option_parser do |o|
        o.separator "#{ hi 'description:' } wanktasktic awesomeness"

        o.separator "#{ hi 'options:' }"

        o.on '-z', '-zeeple'

        # o.banner = @mechanics.last_hot.usage_line
        o.banner = "beauford\nbeuford\nburger"
      end

      def foo
      end
    end
  end

  do_invoke = Do_invoke_[]

  describe "#{ Face::CLI } option help" do

    extend This_TestSupport

    context "typical" do

      let :client_class do Beffer::CLI_Client end

      it "summarizing optparse content works" do
        invoke '-h'
        _dn, up = 2.times.map { unstylize lines[:err].pop }
        up.should match( /\A[ ]*foo [ ]+beauford \[\.\./ )
      end

      it "showing optparse content in help screen works" do
        invoke 'foo', '-h'
        lines[ :err ][ 0, 3 ].join( '_' ).
          should eql( 'beauford_beuford_burger' )
      end
    end

    module This_TestSupport::Deffer

      class CLI_Client < Face::CLI

        # set :num_summary_lines, 3

        option_parser do |o|

          o.banner = "big\nbad\nbeautiful\nbilbo"

        end
      end
    end

    context "more than one summary line per item" do
      it "hm.."
    end
  end

  if do_invoke  # try executing this file directly, passing '-x'
    Beffer::CLI_Client.new( nil, SO_, SE_ ).invoke( ::ARGV )
  end
end
