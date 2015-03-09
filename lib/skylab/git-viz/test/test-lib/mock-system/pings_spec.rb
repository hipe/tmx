require_relative 'test-support'

module Skylab::GitViz::TestSupport::Test_Lib::Mock_System

  describe "[gv] test lib - mock system - pings" do

    extend TS_

    it 'loads' do
      GitViz_::Test_Lib_::Mock_System
    end

    context "employment" do

      before :all do
        class Employer
          GitViz_::Test_Lib_::Mock_System[ self ]
        end
      end

      it "you get a `mock_system_conduit` instance method" do
        Employer.should be_private_method_defined :mock_system_conduit
      end

      it "you need to have a `nearest_test_node` hook-out to use this" do
        -> do
          Employer.new.send :mock_system_conduit
        end.should raise_error ::NoMethodError,
          /\bundefined method `nearest_test_node' for .+::Employer:/
      end
    end

    context "usement" do
      before :all do
        class Eg_Context
          GitViz_::Test_Lib_::Mock_System[ self ]
          def initialize fm
            @fixtures_module = fm ; nil
          end
          attr_reader :fixtures_module  # #hook-in to mock system, mock FS
        end
      end

      it "`mock_system_conduit` does something" do
        ( ! test_context.send( :mock_system_conduit ) ).should eql false
      end

      it "command not found" do
        -> do
          popn3 'no-way', 'jose'
        end.should raise_error ::KeyError,
          /\bnot in the manifest: [«'"]?no-way jose/
      end

      it "multiple commands" do
        -> do
          popn3 'neek-my-deek', foo: :foo
        end.should raise_error ::KeyError,
          /\bmultiple entries have the options: \{"foo":"foo"\}.+command wa/
      end

      it "command with options not found" do
        -> do
          popn3 'nerk-my-derk', '--ok', foo: :bat
        end.should raise_error ::KeyError,
          /\bnone of the 2 command\(s\) have the options: \{"foo":"bat"\}/
      end

      it "ping is a success" do
        popn3 'mock-ping', '--message="derkiss"'
        @o.gets.should eql "hello from mock-system.\n"
        @o.gets.should eql "you said \"derkiss.\" goodbye.\n"
        @o.gets.should be_nil
        @e.gets.should be_nil
        @w.value.exitstatus.should be_zero
      end

      it "command is a succcess" do
        popn3 'nerk-my-derk', '--ok', foo: :biz
        @o.gets.should eql "zoipey\n"
        @o.gets.should eql "doipey\n"
        @o.gets.should be_nil
        @e.gets.should be_nil
        @w.value.exitstatus.should be_zero
      end

      def popn3 *a
        @i, @o, @e, @w = mock_system_conduit.popen3( * a ) ; nil
      end

      -> do
        omg = nil
        define_method :mock_system_conduit do
          omg ||= test_context.send :mock_system_conduit
        end
      end.call

      def test_context
        @test_context ||= build_test_context
      end
      def build_test_context
        Eg_Context.new self.class.nearest_test_node::Fixtures
      end
    end
  end
end
