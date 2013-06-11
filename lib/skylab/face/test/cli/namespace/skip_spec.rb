#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Namespace::Skip

  ::Skylab::Face::TestSupport::CLI::Namespace[ This_TestSupport = self ]

  CONSTANTS::Common_setup_[ self ]

  module Wiffle
    module CLI
      class Client < Face::CLI
        namespace :'alcoa', aliases: ['ac'], skip: true do
          def foo
          end
        end
        namespace :lienenkugel, -> do

        end
        namespace :'tsing-tao', -> do
          TT
        end, :skip, true, :aliases, ['tt']
      end
    end
    class TT < Face::Namespace
      def bar
      end
    end
  end

  do_invoke = Do_invoke_[]

  describe "#{ Face::CLI }::Namespace desc" do

    extend This_TestSupport

    context "some context" do

      let :client_class do Wiffle::CLI::Client end

      it "skips a) strange ns's with empty yield, b/c) 2 kinds of skip" do
        invoke '-h'
        a = []
        2.times do
          a << unstylize( lines[ :err ].pop )
        end
        down, up = a
        up.should match( /\bcommands?:/i )
        down.should match( /for help/i )
      end

      it "(does thing with load failure, that we snuck in here" do
        client.instance_variable_get(:@mechanics).sheet.command_tree._order.
          should eql( [ :lienenkugel ] )
        x = invoke 'lienenkugel'
        lines[:err].shift.should match( /lienenkugel.+command failed to load/i )
        x.should eql( nil )
      end
    end
  end

  if do_invoke  # try executing this file directly, passing '-x'
    Wiffle::CLI::Client.new( nil, SO_, SE_ ).invoke( ::ARGV )
  end
end
