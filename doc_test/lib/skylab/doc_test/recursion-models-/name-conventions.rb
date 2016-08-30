module Skylab::DocTest

  class RecursionModels_::NameConventions

    class << self

      def instance__
        @___ ||= new.__init_with_defaults.freeze
      end
    end  # >>

    def initialize
    end

    def __init_with_defaults
      @test_directory_entry_name = 'test'
      self
    end

    attr_reader(
      :test_directory_entry_name,
    )
  end
end
