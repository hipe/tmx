require_relative 'test-support'

module Skylab::FileMetrics::TestSupport::CLI

  # Quickie.

  describe "[fm] CLI" do

    extend TS_

    exptng = 'line-count or dirs or ext'  # string *and* rx fragment

    as :expecting, /\AExpecting #{ exptng }\.\z/i, :styled
    as :invite, /\ATry fm -h \[sub-cmd\] for help\.?\z/i, :styled

    context "nothing" do
      ptrn '0'
      desc 'nothing'
      argv
      expt :expecting, :invite
      it does do
        invoke argv
        expect expt
      end
    end

    as :usage, /\Ausage: fm \{line-count\|dirs\|ext\} \[opts\] \[args\]\z/i,
      :styled
    as :adtl_usage, /\A {2,}fm \{-h \[cmd\]\}\z/, :nonstyled
    as :option_hdr, /\Aoption:\z/i, :styled
    as :help_option,
      /\A {2,}-h, --help \[cmd\] {2,}this screen.+sub/i, :nonstyled
    as :command_hdr, /\Acommands:\z/i, :styled
    as :branch_invite,
      /\ATry fm -h <sub-cmd> for help on a particular command\.?\z/i, :styled

    context "help lvl 0" do
      ptrn '1.3'
      desc 'help lvl 0'
      argv '-h'
      expt :usage, :adtl_usage, :option_hdr, :help_option, :command_hdr
      it does do
        invoke argv
        expect_partial expt
        expect_styled_line( /\A {2,}line-count {2,}[^ ]/ )
        expect_styled_line( /\A {2,}dirs {2,}[^ ]/ )
        expect_styled_line( /\A {2,}ext {2,}[^ ]/ )
        expect [ :branch_invite ]
      end
    end

    context "help lvl 1" do
      ptrn '2.3x4'
      desc 'help lvl 1'
      argv 'lc', '-h'
      expt_desc 'the whole screen'
      it does do
        invoke argv
        x = whole_err_string
        str = FM_.lib_.brazen::CLI::Styling.unstyle_styled x
        str.should match( /^usage: fm line-count (?:\[[^\[]+){7,}/ )
        str.should match( /^description:.+usage:.+options:.+/m )
      end
    end
  end
end
