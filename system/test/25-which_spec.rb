require_relative 'test-support'

module Skylab::System::TestSupport

  describe "[sy] which" do

    TS_[ self ]

    it "works #fragile" do  # an `ed` has to be installed on the system and in the PATH

      expected_s = _THE_STANDARD_EDITOR
      full_path_s = __parent_subject.which expected_s
      actual_s = full_path_s[ - expected_s.length, expected_s.length ]
      expect( actual_s ).to eql expected_s
    end

    define_method :_THE_STANDARD_EDITOR, -> do

      _ = 'ed'.freeze
      -> { _ }
    end.call

    def __parent_subject

      services_
    end
  end
end
