require_relative 'test-support'

module Skylab::Headless::TestSupport::System::Services::Filesystem

  describe "[hl] system - services - FS - grep (a HACK)" do

    it "minimal case - " do
      parent_subject.grep( :ruby_regexp, /foo/ ).string.should eql "grep -E foo"
    end

    it "unsupported options, no listener" do
      parent_subject.grep( :ruby_regexp, /foo/imx ).should eql false
    end

    it "unsupported options, listener" do
      a = []
      _x = parent_subject.grep( :ruby_regexp, /foo/imx,
        :on_event_selectively, -> * i_a, & ev_p do
        a.push ev_p[]
        a.push i_a
        :_nerp_
      end )
      _x.should eql :_nerp_
      a.last.should eql [ :error, :regexp_option_not_supported ]
      a.first.render_all_lines_into_under y=[],
        Headless_::Lib_::Bzn_[]::API.expression_agent_instance
      y.should eql [ "non convertible regexp options - '[:MULTILINE, :EXTENDED]'" ]
    end

    it "a fully monty" do

      cmd = parent_subject.grep :ruby_regexp, /\bZO[AEIOU]NK\b/i,
        :path, here_path

      cmd_string = cmd.string

      _, o, e, t = Headless_::Library_::Open3.popen3 cmd_string

      e.gets.should be_nil
      line = o.gets
      o.gets.should be_nil

      line.should be_include "-->ZOINK<--"

      t.value.exitstatus.should be_zero

    end

    it "scan" do
      a = []
      scan = parent_subject.grep :ruby_regexp, /foo[b]ie/i,
        :path, here_path, :as_normal_value, -> cmd do
            cmd.to_stream
          end,
        :on_event_selectively, -> * i_a, & ev_p do
            a.push i_a
            a.push ev_p.[]
          end

      a.length.should be_zero
      scan.gets.should be_include 'foobie'
      scan.gets.should be_include 'FOOBIE'
      scan.gets.should be_nil
    end

    def here_path
      TS_.dir_pathname.join( 'grep_spec.rb' ).to_path
    end

    def parent_subject
      Headless_.system.filesystem
    end
  end
end
