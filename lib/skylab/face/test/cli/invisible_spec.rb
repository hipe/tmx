#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Invisible

  ::Skylab::Face::TestSupport::CLI[ This_TestSupport = self ]

  CONSTANTS::Common_setup_[ self ]

  do_invoke = Do_invoke_[]

  describe "#{ Face::CLI } `set node (invisible)` API" do

    extend This_TestSupport

    context "an implicit command made invisible declaratively beforehand" do

      module Cornholius  # guess where this module goes to live

        class CLI_Client < Face::CLI

          def glo
          end

          set :node, :plo, :invisible

          def plo
            :diplo
          end

          def flo
          end
        end
      end

      let :client_class do Cornholius::CLI_Client end

      it "help screen ok" do
        invoke '-h'
        lines[:err].first.include?( '{glo|flo}' ).should eql( true )
      end

      it "invokes the invisible command" do
        res = invoke 'plo'
        res.should eql( :diplo )
      end
    end

    context "implicit, afterhand" do
      module Dornholius
        class CLI_Client < Face::CLI
          def doo
            :doox
          end
          set :node, :doo, :invisible
        end
      end
      let :client_class do Dornholius::CLI_Client end
      it 'does not list' do
        invoke '-h'
        expect_no_help
      end
      it 'does not expect' do
        invoke 'meep'
        expect_nothing
      end
      it 'executes' do
        invoke( 'doo' ).should eql( :doox )
      end
    end

    context "an explicit command, made invisible declaratively beforehand." do

      module Eornholius

        class CLI_Client < Face::CLI

          def glouchester
          end

          set :node, :ping_pong, :invisible

          option_parser do |o|
          end

          def ping_pong
            :ping_pongx
          end

          def worchester
          end
        end
      end

      let :client_class do Eornholius::CLI_Client end

      it "business time - invisibility works in help screen (2 places)" do
        invoke '-h'
        e = lines[:err]
        e[-1].include?( 'command' ).should eql( true )
        e[-2].include?( 'worchester' ).should eql( true )
        e[-3].include?( 'glouchester' ).should eql( true )
        e[-4].include?( 'commands:' ).should eql( true )

        e[0].include?( '{glouchester|worchester}' ).should eql( true )
      end
      it "when reporting expecting" do
        invoke 'meep'
        unstylize_stylized( lines[:err].fetch 0 ).should match(
          /unrec.+meep.+expect.+glouchester or worchester/i )
      end
      it "when invoking the invisible" do
        invoke( 'ping-pong' ).should eql( :ping_pongx )
      end
    end

    context "exlicit during" do
      module Fornholius
        class CLI_Client < Face::CLI
          option_parser do |o|
          end
          set :node, :foo, :invisible
          def foo
            :foox
          end
        end
      end
      let :client_class do Fornholius::CLI_Client end
      it 'does not list' do
        invoke '-h'
        expect_no_help
      end
      it 'does not expect' do
        invoke 'meep'
        expect_nothing
      end
      it 'executes' do
        invoke( 'foo' ).should eql( :foox )
      end
    end

    context "explicit after" do
      module Gornholius
        class CLI_Client < Face::CLI
          option_parser do |o|
          end
          def goo
            :goox
          end
          set :node, :goo, :invisible
        end
      end
      let :client_class do Gornholius::CLI_Client end
      it 'does not list' do
        invoke '-h'
        expect_no_help
      end
      it 'does not expect' do
        invoke 'meep'
        expect_nothing
      end
      it 'executes' do
        invoke( 'goo' ).should eql( :goox )
      end
    end

    def expect_nothing
      lines[:err].fetch( 0 ).should match( /unrec.+meep.+expect.+nothing/i )
    end

    def expect_no_help
      a = lines[:err]
      a.length.should eql( 4 )  # ..meh
    end
  end

  if do_invoke  # try executing this file directly, passing '-x'
    Eornholius::CLI_Client.new( nil, SO_, SE_ ).invoke ::ARGV
  end
end
