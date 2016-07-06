module Skylab::Task::TestSupport

  module Magnetics::CLI

    def self.[] tcc
      Require_zerk_[]
      Zerk_.test_support::Non_Interactive_CLI[ tcc ]
      tcc.include self
    end

    def subject_CLI
      Home_::Magnetics::CLI
    end
  end
end
