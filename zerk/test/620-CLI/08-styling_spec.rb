require_relative '../test-support'

module Skylab::Zerk::TestSupport

  describe "[ze] CLI - styling" do

    it "loads" do
      _subject_module || fail
    end

    it "styles" do

      _act = _subject_module::Stylize[ 'blue', :strong, :red ]
      _act == "\e[1;31mblue\e[0m" || fail
    end

  context "chunker" do

    it "loads" do
      _subject_module::Chunker
    end

    it "chunks & unstyles" do

      mod = _subject_module

      _s = "foo #{ mod.stylize 'bar', :blue } baz"

      _sexp = mod.parse_styles _s

      types = []
      strings = []

      mod::Chunker.via_sexp( _sexp ).each do | pt |

        types.push pt.fetch( 0 ).fetch( 0 )
        strings.push mod.unstyle_sexp pt
      end

      types.should eql [ :string, :style, :string ]

      strings.should eql ["foo ", "bar", " baz" ]
    end
  end

    def _subject_module
      Home_::CLI::Styling
    end
  end
end
