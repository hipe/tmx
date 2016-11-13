require_relative '../test-support'

module Skylab::Common::TestSupport

  describe "[co] event - wrappers file utils message" do

    TS_[ self ]
    use :the_method_called_let

    context 'mkdir -p' do

      let :arg do
        '-i am a filename'
      end

      def cmd
        :mkdir_p
      end

      it "ok." do
        expect 'mkdir -p'
      end
    end

    it "(stowaway - tmx integration)" do

      Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'common', 'ping'

      cli.expect_on_stderr "hello from common.\n"

      cli.expect_succeeded_under self
    end

    def expect expect_s
      s = fu_output_message_for cmd, arg
      md = _subject.match s
      md or fail "did not match: #{ s.inspect }"
      md[ :predicate ].should eql expect_s
      md[ :argument ].should eql arg
    end

    def fu_output_message_for i, s
      message = nil
      _fuc = Home_.lib_.system.filesystem.file_utils_controller do | msg |
        message = msg
      end
      _fuc.send i, s, noop: true
      message
    end

    def _subject
      Home_::Event::Via_file_utils_message::PATH_HACK_RX__
    end
  end
end
