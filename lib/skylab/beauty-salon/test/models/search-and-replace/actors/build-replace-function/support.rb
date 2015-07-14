require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport::Models::Search_and_Replace::Repl

  Parent_TS_ = ::Skylab::BeautySalon::TestSupport::Models::Search_and_Replace

  Parent_TS_[ TS_ = self ]

  include Constants

  extend TestSupport_::Quickie

  module InstanceMethods

    def rf replace_function_string
      @replace_function = Parent_TS_::Subject_[]::Actors_::Build_replace_function[
        replace_function_string,
        :_no_work_dir_,
        -> *, & ev_p do
          @ev_a ||= []
          @ev_a.push ev_p[]
          false
        end ]
      nil
    end

    def rx rx
      @ruby_regexp = rx ; nil
    end

    def against input_string
      @output_string = input_string.gsub @ruby_regexp do
        @replace_function.call $~
      end ; nil
    end

    def expect expect_string
      @output_string.should eql expect_string
    end
  end
end
