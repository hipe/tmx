#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Set

  ::Skylab::Face::TestSupport::CLI[ This_TestSupport = self ]

  CONSTANTS::Common_setup_[ self, :sandbox ]

  module Awoooga

    class CLI_Client < Face::CLI

      set :margin, 12

      option_parser do |o|
        o.banner = "foozie\ndoozie\nboozie"
      end

      def fluzi
      end

      def meeper deeper, creeper=nil
      end
    end
  end

  do_invoke = Do_invoke_[]

  describe "#{ Face::CLI } `set` API" do

    extend This_TestSupport

    context "some context" do

      let :client_class do Awoooga::CLI_Client end

      it "business time - only at level 1" do
        invoke '-h'
        line = unstylize_stylized lines[ :err ][ -2 ]
        a, b = /\A([ ]+)meeper([ ]+)/.match( line ).captures
        a.length.should eql( 12 )
        a.should eql( b )
      end
    end
  end

  if do_invoke  # try executing this file directly, passing '-x'
    Awoooga::CLI_Client.new( nil, SO_, SE_ ).invoke( ::ARGV )
  end
end
