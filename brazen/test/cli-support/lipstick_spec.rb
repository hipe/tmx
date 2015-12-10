require_relative '../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] CLI support - lipstick" do

    it "one segment" do

      _LIPSTICK = _subject_module.build_with(

        :segment,
          :glyph, '*',
          :color, :yellow,
        :expression_width_proc, -> { 20 } )

      _rendering_proc = _LIPSTICK.new_expressor

      line = _rendering_proc[ 0.50 ]  # must be btwn 0.0 and 1.0 inclusive

      line = _unstyle_styled line

      md = /\A(?<pluses>\*+)(?<spaces>[ ]+)\z/.match line

      md[ :pluses ].length.should eql 10
      md[ :spaces ].length.should eql 10  # :+[#073.A]
    end

    it "multiple segments" do

      _LIPSTICK = _subject_module.build_with(

        :segment,
          :glyph, '+',
          :color, :green,
        :segment,
          :glyph, '-',
          :color, :red

        # expression width should default to for e.g 72
      )

      _rendering_proc = _LIPSTICK.new_expressor_with(
        :expression_width, 60
      )

      line = _rendering_proc[ 0.50, 0.25 ]

      line = _unstyle_styled line

      line.should eql "#{ '+' * 30 }#{ '-' * 15 }"
    end

    def _subject_module
      Home_::CLI_Support::Lipstick
    end

    def _unstyle_styled s

      s_ = Home_::CLI_Support::Styling.unstyle_styled s
      if s_
        s_
      else
        fail "was not styled: #{ s.inspect }"
      end
    end
  end
end