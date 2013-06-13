#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::CodeMolester::TestSupport::Config::Service

  ::Skylab::CodeMolester::TestSupport::Config[ TS_ = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  CodeMolester = CodeMolester

  describe "#{ CodeMolester }::Config::Service" do

    context "provide some arguments" do
      m = -> do
        module M1
          class Client
            CodeMolester::Config::Service.enhance self do
              filename 'foo.config'
              search_num_dirs do 3 end
            end
          end
        end
        m = -> { }
        nil
      end
      before :each do m[] end
      it "you can retrieve them" do
        c = M1::Client.new
        c.config.filename.should eql( 'foo.config' )
        c.config.search_num_dirs.should eql( 3 )
      end
    end

    context "just accept raw defaults" do
      m = -> do
        module M2
          class Client
            CodeMolester::Config::Service.enhance self
          end
        end
        m = -> { }
        nil
      end
      before :each do m[] end
      it "let's see what happens.." do
        c = M2::Client.new ; cfg = c.config
        pwd = ::Dir.pwd
        cfg.search_num_dirs.should eql( 3 )
        cfg.search_start_pathname.should eql( pwd )
        cfg.default_init_directory.should eql( pwd )
        cfg.filename.should eql( 'config' )
      end
    end
  end
end
