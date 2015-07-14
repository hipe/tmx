require_relative '../../../test-support'

module Skylab::BeautySalon::TestSupport

  # Home_::Lib_::Face__[]::TestSupport::CLI::Client[ self ]

  describe "[bs] CLI wrap", wip: true do

    def self.client_class
      Home_::CLI::Client
    end

    it "win" do

      path = TestSupport_::Data::Universal_Fixtures.dir_pathname.
        join "one-line.txt"

      invoke 'wrap', '-c14', '-v', path

      lines[ :err ].first.should match %r(\bline range union: 1-infinity\b)i

      output_lines = lines[ :out ]
      output_lines.length.should eql 5
      output_lines.first.should eql "a file with"

    end
  end
end
