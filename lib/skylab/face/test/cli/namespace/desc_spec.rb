#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Namespace::Desc

  ::Skylab::Face::TestSupport::CLI::Namespace[ This_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module Sandbox
  end

  CONSTANTS::Sandbox = Sandbox

  Face = Face

  module Wowzaa
    module CLI
      class Client < Face::CLI

        set :num_summary_lines, 2

        use :hi

        option_parser do |o|
          o.banner = "today\ntoday we're gonna"
        end

        def live_like
        end

        namespace :throw_it_in_a_fire, :desc, -> y do
          y << "#{ hi 'description:' } live"
          y << '  like'
          y << '  a warrior'
          y << nil
        end do
          def throw_it_in_a_fire
          end
        end
      end
    end
  end

  do_invoke = Do_invoke_[]

  describe "#{ Face::CLI }::Namespace desc" do

    extend This_TestSupport

    context "some context" do

      let :client_class do Wowzaa::CLI::Client end

      it "the index screen - how this works into summaries.." do
        invoke '-h'
        a = lines[ :err ][ -5 .. -2 ].map( & method( :unstylize ) ).reverse
        a.pop.should eql( "           live-like  today" )
        a.pop.should eql( "                      today we're gonna" )
        a.pop.should eql( "  throw-it-in-a-fire  live" )
        a.pop.should eql( "                      like [..]" )
      end

      it "the help screen - the *surface* context is used!" do
        invoke 'throw', '-h'
        a = lines[ :err ][ 2 .. 5 ].reverse
        unstylize_stylized( a.pop ).should eql( 'description: live' )
        a.pop.should eql( '  like' )
        a.pop.should eql( '  a warrior' )
        a.pop.should eql( '' )
      end
    end
  end

  if do_invoke  # try executing this file directly, passing '-x'
    Wowzaa::CLI::Client.new( nil, SO_, SE_ ).invoke( ::ARGV )
  end
end
