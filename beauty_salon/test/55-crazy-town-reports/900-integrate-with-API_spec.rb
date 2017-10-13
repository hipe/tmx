# frozen_string_literal: true

require_relative '../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy town reports - integrate with API', ct: true do

    TS_[ self ]
    use :my_API
    use :modality_agnostic_interface_things

    dig = %i( crazy_town )

    context 'call with not enough args' do

      it 'NOTE we have hardcoded CLI things' do
        _actual = _lines
        expect_these_lines_in_array_ _actual do |y|
          y << "must have one of --files-file, <files> or --corpus-step"
        end
      end

      shared_subject :_lines do

        _the_file = fixture_functions_ 'la-la-020.rb'

        call( * dig,
          :replace,
          :code_selector, %{send(method_name=='xx')},
          :replacement_function, "file:#{ _the_file }",
        )

        lines = nil
        expect :error, :expression do |y|
          lines = y
        end
        expect_result nil
        lines
      end
    end

    # ==

    # ==
    # ==
  end
end
