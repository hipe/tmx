#!/usr/bin/env ruby -w

require_relative 'test-support'

module Skylab::CodeMolester::TestSupport::Config::Service

  ::Skylab::CodeMolester::TestSupport::Config[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  CM_ = CM_

  describe "[cm] config service" do

    context "provide some arguments" do
      m = -> do
        module M1
          class Client
            CM_::Config::Service.enhance self do
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
            CM_::Config::Service.enhance self
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
        cfg.search_start_path.should eql( pwd )
        cfg.default_init_directory.should eql( pwd )
        cfg.filename.should eql( 'config' )
      end
    end

    context "`search_search_path` vs. `get_search_start_pathname`" do
      m = -> do
        module M3
          class Client
            CM_::Config::Service.enhance self do
              search_start_path '/wizzo'
            end
          end
        end
        m = -> { }
        nil
      end
      before :each do m[] end

      let :cfg do
        M3::Client.new.config
      end

      it "the one is derivative of the other" do
        cfg.search_start_path.should eql( '/wizzo' )
        cfg.get_search_start_pathname.join( 'pizzo' ).to_s.
          should eql( '/wizzo/pizzo' )
      end

      it "the other is not memoized - set the one, changes the other" do
        pn1 = cfg.get_search_start_pathname
        cfg.search_start_path = '/foo'
        pn2 = cfg.get_search_start_pathname
        pn1.to_s.should eql( '/wizzo' )
        pn2.to_s.should eql( '/foo' )
      end
    end
  end
end
