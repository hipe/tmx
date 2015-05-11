require_relative '../../test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - FS - grep (a HACK)" do

    extend TS_

    it "minimal case - " do
      _parent_subject.grep( :ruby_regexp, /foo/ ).string.should eql "grep -E foo"
    end

    it "unsupported options, no listener" do
      _parent_subject.grep( :ruby_regexp, /foo/imx ).should eql false
    end

    it "unsupported options, listener" do

      a = []

      _x = _parent_subject.grep( :ruby_regexp, /foo/imx,
        :on_event_selectively, -> * i_a, & ev_p do
        a.push ev_p[]
        a.push i_a
        :_nerp_
      end )

      _x.should eql :_nerp_

      a.last.should eql [ :error, :regexp_option_not_supported ]

      a.first.express_into_under y=[],
        System_.lib_.brazen::API.expression_agent_instance

      y.should eql [ "non convertible regexp options - '[:MULTILINE, :EXTENDED]'" ]
    end

    it "a fully monty" do

      cmd = _parent_subject.grep :ruby_regexp, /\bZO[AEIOU]NK\b/i,
        :path, _here_path

      cmd_string = cmd.string

      _, o, e, t = System_.lib_.open3.popen3 cmd_string

      e.gets.should be_nil
      line = o.gets
      o.gets.should be_nil

      line.should be_include "-->ZOINK<--"

      t.value.exitstatus.should be_zero

    end

    it "scan" do
      a = []
      scan = _parent_subject.grep :ruby_regexp, /foo[b]ie/i,
        :path, _here_path, :as_normal_value, -> cmd do
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

    define_method :_here_path, ( Callback_.memoize do  # `memoize_`
      TS_.dir_pathname.join( 'services/filesystem/grep_spec.rb' ).to_path
    end )

    def _parent_subject
      services_.filesystem
    end
  end
end
