module Skylab::SearchAndReplace::TestSupport

  module Fixture_Trees

    class << self

      def [] entry_s
        ::File.join _dir_path, entry_s
      end

      def _dir_path
        @___ ||= dir_pathname.to_path
      end

    end  # >>

    Self__ = self
  end
end
