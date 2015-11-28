require_relative '../../../test-support'

module Skylab::System::TestSupport

  module Doubles_StubbedSystem_Namespace

    o = TS_.lib_ :doubles_stubbed_system

    Subject__ = o::Subject
    Path_for__ = o::Path_for

    # <-

  TS_.describe "[sy] doubles - stubbed-system - 05: full integration example" do

    TS_[ self ]
    o[ self ]

    before :all do

      class MS_05_Fake_Test_Context

        Subject__[].enhance_client_class self

        define_method :cache_hash_for_stubbed_system, ( Callback_.memoize do
          {}
        end )

        define_method :manifest_path_for_stubbed_system, ( Callback_.memoize do

          Path_for__[ '05-full-integration-example/fixtures/commands.ogdl' ]

        end )
      end
    end

    it "enhance your test context module in the common way" do
      # if this doesn't fail it succeeds
    end

    it "look a ping" do

      tc = _test_context_instance
      _, o, e, t = tc.stubbed_system_conduit.popen3 'echo', 'hello'
      t.value.exitstatus.should be_zero
      e.should be_nil  # you get none because you had none
      o.gets.should eql "hello\n"
      o.gets.should be_nil
    end

    it "if you submit a command that isn't in manifest, key error is raised" do

      begin
        _stubbed_system_conduit.popen3( 'not', 'there' )
      rescue ::KeyError => e
      end
      e.message.should match(
        /\Ano such mock command \["not", "there"\] in [^ ]+\.ogdl"\z/ )
    end

    it "you can't reach a command that doesn't have a pwd with a pwd" do

      _hack_lookup( 'echo', 'hello', chdir: 'xx' ).should be_nil
    end

    it "you can't reach a command that has a pwd without the same pwd" do

      _hack_lookup( 'echo', 'hi' ).should be_nil
    end

    it "with a command with a pwd, you must use the pwd" do

      _hack_lookup( 'echo', 'hi', chdir: 'x/y' ).exitstatus.should eql 777
    end

    def _hack_lookup * args
      _stubbed_system_conduit.instance_variable_get( :@lookup )[ args ]
    end

    def _stubbed_system_conduit
      _test_context_instance.stubbed_system_conduit
    end

    memoize :_test_context_instance do
      MS_05_Fake_Test_Context.new
    end
  end
# ->
  end
end
