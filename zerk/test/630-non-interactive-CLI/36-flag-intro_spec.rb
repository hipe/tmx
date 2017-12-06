require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] niCLI - flag" do

    TS_[ self ]
    use :memoizer_methods
    use :non_interactive_CLI

    context "dry run is off is off" do

      given do
        argv 'money'
      end

      it "succeeds" do
        succeeds
      end

      it "welff here is behavior for the FalseClass value" do

        o = first_line
        o.stream_symbol == :o or fail
        o.string == "no\n" or fail
      end
    end

    context "dry run is on is on" do

      given do
        argv 'money', '--probe-lauf'
      end

      it "succeeds" do
        succeeds
      end

      it "welff here is behavior for the TrueClass value" do

        o = first_line
        o.stream_symbol == :o or fail
        o.string == "yes\n" or fail
      end
    end

    context "omg help screen" do

      given do
        argv 'money', '-h'
      end

      it "option is option" do
        _option_line.long == '--probe-lauf' or fail
      end

      it "desc is there" do
        _option_line.desc == "'Probelauf' is German for \"test run\"." or fail
      end

      shared_subject :_option_line do
        _cp = TS_::CLI::Want_Section_Coarse_Parse.via_line_object_array niCLI_state.lines
        _dex = _cp.section( :options ).to_option_index
        _dex.h_.fetch '-p'
      end
    end

    def subject_root_ACS_class
      My_fixture_top_ACS_class[ :Class_36_Flag ]
    end
  end
end
