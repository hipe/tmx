require_relative '../test-support'

module Skylab::Tabular::TestSupport

  describe "[tab] models - schema (intro)" do

    TS_[ self ]
    use :memoizer_methods

    context "(context)" do

      it "builds" do
        _schema
      end

      it "knows its length" do
        _schema.number_of_columns == 2 || fail
      end

      it "knows the first field's name and that it is NOT numeric" do

        fld = _schema.field_box.at_position 0
        fld.name.as_human == "test directory" || fail
        fld.is_numeric && fail
      end

      it "knows the second field's name and that it IS numeric" do

        fld = _schema.field_box.at_position 1
        fld.normal_name_symbol == :number_of_test_files || fail
        fld.is_numeric || fail
      end

      shared_subject :_schema do

        Home_::Models::TableSchema.define do |o|

          o.add_field_via_normal_name_symbol :test_directory
          o.add_field_via_normal_name_symbol :number_of_test_files, :numeric
        end
      end
    end
  end
end
# #born: to cover how this was used during production, for grand unification.
