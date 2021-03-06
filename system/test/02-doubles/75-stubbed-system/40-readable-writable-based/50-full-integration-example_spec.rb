require_relative '../../../test-support'

module Skylab::System::TestSupport

  module Doubles_StubbedSystem_Namespace

    o = TS_.lib_ :doubles_stubbed_system

    Subject__ = o::Subject

    # <-

  TS_.describe "[sy] doubles - stubbed-system - full integration example" do

    TS_[ self ]
    o[ self ]

    before :all do

      class MS_05_Fake_Test_Context

        lib = Doubles::Stubbed_System

        lib::Subject[].enhance_client_class self

        define_method :cache_hash_for_stubbed_system, ( Common_.memoize do
          {}
        end )

        define_method :manifest_path_for_stubbed_system, ( Common_.memoize do

          Fixture_file_[ 'ogdl-commands.05.ogdl' ]
        end )
      end
    end

    it "enhance your test context module in the common way" do
      # if this doesn't fail it succeeds
    end

    it "look a ping" do

      tc = _test_context_instance

      _sc = tc.stubbed_system_conduit

      _, o, e, t = _sc.popen3 'echo', 'hello'

      expect( t.value.exitstatus ).to be_zero
      expect( e ).to be_nil  # you get none because you had none
      expect( o.gets ).to eql "hello\n"
      expect( o.gets ).to be_nil
    end

    it "if you submit a command that isn't in manifest, key error is raised" do

      begin
        _stubbed_system_conduit.popen3( 'not', 'there' )
      rescue ::KeyError => e
      end
      expect( e.message ).to match(
        /\Ano such mock command \["not", "there"\] in [^ ]+\.ogdl"\z/ )
    end

    it "you can't reach a command that doesn't have a pwd with a pwd" do

      expect( _hack_lookup( 'echo', 'hello', chdir: 'xx' ) ).to be_nil
    end

    it "you can't reach a command that has a pwd without the same pwd" do

      expect( _hack_lookup( 'echo', 'hi' ) ).to be_nil
    end

    it "with a command with a pwd, you must use the pwd" do

      expect( _hack_lookup( 'echo', 'hi', chdir: 'x/y' ).exitstatus ).to eql 777
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
