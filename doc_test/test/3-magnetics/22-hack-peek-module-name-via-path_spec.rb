require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] magnetics - hack peek [..]" do

    TS_[ self ]

    it "when matching leaf nodes not found, search branch nodes" do

      _Basic = TS_.testlib_.basic

      _path = ::File.join _Basic.dir_pathname.to_path, 'method.rb'

      _subject( _path ) == "Skylab::Basic::Method" or fail
    end

    it "detect const assignment also #experimental" do

      _whole_string = <<-'HERE'

        module Skorlab::MortaHorl

          module Porse

            Voa_ordered_set__ = Parse::Curry_[ etc ]
          end
        end
      HERE

      _line_ups = Home_.lib_.basic::String.line_stream _whole_string

      _name = _subject(
        :path, '/var/xkcd/skorlorb/morta-horl/porse/voa-ordered-set--.rb',
        :line_upstream, _line_ups,
        & method( :___expect_no_event ) )

      _name == "Skorlab::MortaHorl::Porse::Voa_ordered_set__" or fail
    end

    def ___expect_no_event * i_a
      fail "not expected: #{ i_a.inspect }"
    end

    def _subject * a, & p
      magnetics_module_::Hack_Peek_Module_Name_via_Path[ * a, & p ]
    end
  end
end
