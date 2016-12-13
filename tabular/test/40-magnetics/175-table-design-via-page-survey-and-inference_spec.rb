require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tab] magnetics - table design via page survey and inference" do

    TS_[ self ]
    use :memoizer_methods
    use :magnetics_for_infer_table

    context "minimal normative" do

      it "builds" do
        _table_design || fail
      end

      it "3 defined fields" do
        _table_design.all_defined_fields.length == 3 || fail
      end

      it "last field is fill field" do
        _last_field_is_a_fill_field
      end

      shared_subject :_table_design do
        first_table_design_via_(
          [ 'jleep', 77 ],
          [ 'zleepie', 99 ],
        )
      end
    end

    context "with trailing zero length tuple" do

      it "builds" do
        _table_design || fail
      end

      it "3 defined fields" do
        _table_design.all_defined_fields.length == 3 || fail
      end

      it "last field is fill field" do
        _last_field_is_a_fill_field
      end

      shared_subject :_table_design do
        first_table_design_via_(
          [ 'jleep', 77 ],
          EMPTY_A_,
        )
      end
    end

    def _last_field_is_a_fill_field
      fld = _table_design.all_defined_fields.fetch( -1 )
      fld.is_summary_field || fail
      fld.is_summary_field_fill_field || fail
    end

    def is_first_page
      true
    end

    def is_last_page
      true
    end

    def page_size
      3
    end

    def target_table_width
      40
    end
  end
end
# #born during and for "infer table"
