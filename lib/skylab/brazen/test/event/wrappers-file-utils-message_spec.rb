require_relative 'test-support'

module Skylab::Brazen::TestSupport::Entity::Event::Wrap_FU_msg

  ::Skylab::Brazen::TestSupport::Entity::Event[ self ]

  include Constants

  extend TestSupport_::Quickie

  TestLib_ = TestLib_

  describe "[br] entity event wrappers - file utils message" do

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

    def expect expect_s
      s = fu_output_message_for cmd, arg
      md = Subject_[].match s
      md or fail "did not match: #{ s.inspect }"
      md[ :predicate ].should eql expect_s
      md[ :argument ].should eql arg
    end

    def fu_output_message_for i, s
      message = nil
      _fuc = TestLib_::System[].filesystem.file_utils_controller do |msg|
        message = msg
      end
      _fuc.send i, s, noop: true
      message
    end

    Subject_ = -> do
      Brazen_::Entity::Event__::Wrappers__::File_utils_message::PATH_HACK_RX__
    end
  end
end
