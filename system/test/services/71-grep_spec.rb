require_relative '../test-support'

module Skylab::System::TestSupport

  describe "[sy] - services - grep (a HACK)" do

    TS_[ self ]

    it "minimal case - string looks like command" do

      _g = _parent_subject.grep :ruby_regexp, /foo/
      _s = _g.to_command_string
      _s.should eql "grep -E foo"
    end

    it "unsupported options, no listener" do

      _g = _parent_subject.grep :ruby_regexp, /foo/imx
      _g.should eql false
    end

    it "unsupported options, listener" do

      a = []

      _x = _parent_subject.grep(

        :ruby_regexp, /foo/imx,

      ) do | * i_a, & ev_p |

        a.push ev_p[]
        a.push i_a
        :_never_see
      end

      _x.should eql false  # unreliable

      a.last.should eql [ :error, :regexp_option_not_supported ]

      a.first.express_into_under y=[],
        Home_.lib_.brazen::API.expression_agent_instance

      y.should eql [ "non convertible regexp options - 'MULTILINE', 'EXTENDED'" ]
    end

    it "a fully monty" do

      _grep = _parent_subject.grep(
        :ruby_regexp, /\bZO[AEIOU]NK\b/i,
        :path, _here_path,
      )

      _toks = _grep.to_command_tokens

      _, o, e, t = Home_.lib_.open3.popen3( * _toks )

      e.gets.should be_nil
      line = o.gets
      o.gets.should be_nil

      line.should be_include "-->ZOINK<--"

      t.value.exitstatus.should be_zero
    end

    it "hits the system if you want it to" do
      a = []

      _cmd = _parent_subject.grep(

        :ruby_regexp, /foo[b]ie/i,

        :path, _here_path,

      ) do | * i_a, & ev_p |
        a.push i_a
        a.push ev_p[]
      end

      scan = _cmd.to_output_line_content_stream

      a.length.should be_zero
      scan.gets.should be_include 'foobie'
      scan.gets.should be_include 'FOOBIE'
      scan.gets.should be_nil
    end

    memoize :_here_path do

      ::File.join TS_.dir_path, 'services/71-grep_spec.rb'
    end

    def _parent_subject
      services_
    end
  end
end
