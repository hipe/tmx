require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] niCLI - wowza" do

    TS_[ self ]
    use :my_non_interactive_CLI

    context '(oops)' do

      given do
        argv 'adapter', 'imagemagick', 'OSA-script'
      end

      it 'whines' do
        expect :first_line, "'adapter' (an entitesque) is not accessed with that syntax."
        expect :exitstatus, :_parse_error_
      end

      it 'invites' do
        expect :invite, :from_top, :about_arguments
      end
    end

    context "(missing required components)" do

      given do
        argv '--ada', 'imagema', 'OSA-script'
      end

      it 'hi' do
        expect :penultimate_line, 'can\'t produce an image without "background font" and "label"'
      end

      it "invite (about nothing in particular)" do

        expect :invite, :when_adapter_activated, :from, 'osa-script'
      end
    end

    context "(bad font)" do

      given do
        argv(
          '--ada=ima', 'OSA-script',
          '--bg-font', 'not-a-font',
          '--label', 'djibouti',
        )
      end

      it 'whines EEW' do  # #wish [#016] maybe after #milestone-9

        _ = "bg font failed to OSA script because unrecognized font path \"not-a-font\""
        expect :third_from_last_line, _
      end

      it "did you mean" do

        expect :penultimate_line, %r(\Adid you mean ['"]?[a-z])
      end

      it "invite" do

        expect :invite, :when_adapter_activated, :from, 'osa-script', :about_options
      end
    end

    context "(ok!)" do

      given do
        argv(
          '--ada=ima', 'set-background-image',
          '--bg-font', 'lucida',
          '--label', 'djibouti',
        )
      end

      it "succeeds" do
        expect :succeeds
      end

      it "emits as info the imagemagick command" do
        expect :penultimate_line, %r(\(attempting: convert -font )
      end

      it "says that it set it" do
        expect :last_line, %r(\Aapparently set iTerm background image to )
      end

      def system_conduit_for_niCLI_
        TS_::Stubs::System_Conduit_02_Yay.produce_new_instance
      end
    end
  end
end
