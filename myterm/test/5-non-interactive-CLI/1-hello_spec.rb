require_relative '../test-support'

module Skylab::MyTerm::TestSupport

  describe "[my] niCLI - hello" do

    TS_[ self ]
    use :my_non_interactive_CLI

    context "fundamentals" do

      it "loads" do
        subject_CLI
      end
    end

    context 'ping' do

      given do
        argv 'ping'
      end

      it "whine" do
        expect :exitstatus, :_parse_error_
        expect :first_line, 'unrecognized node name "ping"'
      end

      it "did you mean" do
        expect :second_line, :styled, %r(\Adid you mean '[a-z])
      end

      it "invite" do
        expect :invite, :from_top, :about_arguments
      end
    end

    context "1.2) bad options" do

      given do
        argv '-xyz'
      end

      it "customized whine" do
        expect :exitstatus, :_parse_error_
        expect :first_line, 'expected -h or -a. had "-xyz".'
      end

      it "invite" do
        expect :invite, :from_top, :about_arguments
      end
    end

    context "ending on compound whines" do

      given do
        argv 'adapters'
      end

      it "whines" do
        expect :exitstatus, :_parse_error_
        expect :first_line, :styled, "expecting <compound-or-operation>: { 'list' }"
      end

      it "invite" do
        expect :invite, :from, "adapters", :about_arguments
      end
    end

    context "list adapters!" do

      given do
        argv 'adapters', 'list'
      end

      it "no star" do
        expect :only_line, :o, "  'imagemagick'"
      end
    end

    context "set adapter (bad name)" do

      given do
        argv '-ajabooti', '--xx'
      end

      it "specific whine" do
        expect :first_line, 'unrecognized adapter name "jabooti"'
      end

      it "did you mean" do
        expect :second_line, :styled, "did you mean 'imagemagick'?"
      end

      it "(no invite for now)" do
        expect :number_of_lines, 2
      end
    end

    context "set adapter (good name) - prints star" do

      given do
        argv '-aima', 'adapters', 'list'
      end

      it "first line confirms change" do
        expect :succeeds
        expect :first_line, "set adapter to 'imagemagick'"
      end

      it "lists with star" do
        expect :second_line, :o, "• 'imagemagick'"
      end
    end
  end
end
