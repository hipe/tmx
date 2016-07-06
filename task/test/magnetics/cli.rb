module Skylab::Task::TestSupport

  module Magnetics::CLI

    def self.[] tcc
      tcc.send :define_singleton_method, :given do |*|
      end
    end

    def _WAS
      Require_zerk_[]
      Zerk_.test_support::Non_Interactive_CLI[ tcc ]
      tcc.include self
    end

    def subject_CLI
      Home_::Magnetics::CLI
    end

    def begin_mock_FS_
      self._MOVED_see_history_entry  # (see historical item)
    end
  end
end
