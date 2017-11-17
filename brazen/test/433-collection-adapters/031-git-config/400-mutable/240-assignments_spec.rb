require_relative '../../../test-support'

module Skylab::Brazen::TestSupport

  describe "[br] collection adapters - git config - mutable - assignments" do

    TS_[ self ]
    use :memoizer_methods
    use :want_emission_fail_early
    use :collection_adapters_git_config_mutable

    context "to a section with no assignments" do

      with_a_document_with_a_section_called_foo

      context "add a boolean assignment" do

        it "result is status with lots of info" do

          sct = _tuple[1]
          sct.did_add || fail
          sct.offset.zero? || fail
          sct.did_add_to_end || fail
        end

        it "document is modified correctly" do

          want_these_lines_in_array_with_trailing_newlines_ _actual do |y|
            y << "[foo]"
            y << "is-on = true"
          end
        end

        it "event is structured, has info" do

          ev = _tuple.first
          :added_value == ev.terminal_channel_symbol or fail
          ast = ev.new_assignment
          ast.external_normal_name_symbol.should eql :is_on
          ast.value.should eql true
        end

        shared_subject :_tuple do

          _sect = _dereference_section :foo

          will_call_by_ do |p|
            _sect.assign true, :is_on, & p
          end

          _flush_common_triadic_tuple
        end
      end

      context "quotes will not be used if not necessary" do

        it "document is modified correctly" do

          want_these_lines_in_array_with_trailing_newlines_ _actual do |y|
            y << "[foo]"
            y << "hi = foo bar"
          end
        end

        it "event OK" do
          ev = _tuple.first
          :added_value == ev.terminal_channel_symbol or fail
          ast = ev.new_assignment
          ast.internal_normal_name_string == 'hi' || fail
          ast.value == 'foo bar' || fail
        end

        shared_subject :_tuple do

          _sect = _dereference_section :foo

          will_call_by_ do |p|
            _sect.assign 'foo bar', :'hi', & p
          end

          _flush_common_dyadic_tuple
        end
      end

      context "quotes will be used for leading spaces" do

        it "document is modified correctly" do

          want_these_lines_in_array_with_trailing_newlines_ _actual do |y|
            y << "[foo]"
            y << 'hi = " foo"'
          end
        end

        shared_subject :_tuple do

          _sect = _dereference_section :foo

          will_call_by_ do |p|
            _sect.assign ' foo', :'hi', & p
          end

          _flush_common_monadic_tuple
        end
      end

      context "things get escaped TODO this won't unmarshal" do  # #todo is there still an issue with unmarshalling?

        it "document is modified correctly" do

          want_these_lines_in_array_with_trailing_newlines_ _actual do |y|
            y << "[foo]"
            y << %(hi = \\\\ \\" \\\n \\t \\b)
          end
        end

        shared_subject :_tuple do

          _sect = _dereference_section :foo

          will_call_by_ do |p|
            _sect.assign "\\ \" \n \t \b", :hi, & p
          end

          _flush_common_monadic_tuple
        end
      end
    end

    context "change one existing" do

      with_a_document_with_one_section_with_one_assignment

      it "changes it (minimal)" do  # :#cov1.2
        _sect = _dereference_section :foo
        _sect[ :bar ] = 'win'
        want_document_content "[foo]\nbar = win\n"
      end

      it "changes it when quotes are necessary to add" do

        _sect = _dereference_section :foo
        _sect[ :bar ] = ' a'
        want_document_content "[foo]\nbar = \" a\"\n"
      end
    end

    context "change one existing (from quotes to no quotes)" do

      with_content "[foo]\nbar = \" a\"\n"

      it "changes it when quotes can be removed" do
        _sect = _dereference_section :foo
        _sect[ :bar ] = 11
        want_document_content "[foo]\nbar = 11\n"
      end
    end

    def _actual
      _tuple.last
    end

    def _flush_common_monadic_tuple
      a = _flush_common_dyadic_tuple
      a.first.terminal_channel_symbol == :added_value || fail  # hi.
      a.unshift
      a
    end

    def _flush_common_dyadic_tuple
      a = _flush_common_triadic_tuple
      a[1].did_add  # hi.
      a[1,1] = EMPTY_A_
      a
    end

    def _flush_common_triadic_tuple
      a = []
      want :info, :related_to_assignment_change, :added do |ev|
        a.push ev
      end
      _x = execute
      a.push _x
      a.push document_to_lines_
      a
    end

    def _dereference_section sym
      document.sections.dereference sym
    end

    # ==
  end
end
