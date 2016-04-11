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

      it "invite" do
        expect :invite, :from, "osa-script"
      end
    end

    context "(help)" do

      given do
        argv '--ada=ima', 'OSA-script', '-h'
      end

      it "(readme)" # #until [#010]..
        # the most important thing to test is already exhibited by this
        # helpscreen, which is that the adapter-specific components are
        # reflected in the o.p. but additionally it would be prudent to
        # have the help screen actually reflect what is syntax really is..
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

        _ = "imagemagick couldn't OSA script because bg font unrecognized font path \"not-a-font\""
        expect :third_from_last_line, _
      end

      it "did you mean" do

        expect :penultimate_line, :styled, %r(\Adid you mean ['"]?[a-z])
      end

      it "invite"  # #during [#010] maybe make this better
    end

    context "(ok!)" do

      given do
        argv(
          '--ada=ima', 'set-background-image',
          '--bg-font', 'lucida',
          '--label', 'djibouti',
        )
      end

      it "(fake the system)"

      def system_conduit
        self._ETC
      end
    end
  end
end
