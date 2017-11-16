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
        want 'mkdir -p'
      end
    end

    it "(stowaway - tmx integration)", TMX_CLI_integration: true do

      # #cov1.9

      Autoloader_.require_sidesystem :TMX

      cli = ::Skylab::TMX.test_support.begin_CLI_expectation_client

      cli.invoke 'common', 'ping'

      cli.want_on_stderr "hello from common.\n"

      cli.want_succeed_under self
    end

    def want want_s
      s = fu_output_message_for cmd, arg
      md = _subject.match s
      md or fail "did not match: #{ s.inspect }"
      md[ :predicate ].should eql want_s
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
