module Skylab::SearchAndReplace::TestSupport

  module SES::Replacement

    def self.[] tcc

      tcc.extend SES::Common_DSL::ModuleMethods
      tcc.include SES::Common_DSL::InstanceMethods

      tcc.send :define_singleton_method, :common_DSL_when_givens_are_given, THIS___

      tcc.include SES::InstanceMethods  # build_edit_session_via_

      tcc.include SES::Block_Stream::InstanceMethods  # begin_expect_atoms_for_

      tcc.include self
    end

    # -

      THIS___ = -> do

        shared_subject :_all_lines_after_having_engaged_replacement do

          _s, _rx = common_DSL_string_and_regex

          es = build_edit_session_via_ _s, _rx

          self.apply_some_replacements_ es

          es.to_throughput_line_stream_.to_a
        end

        super()
      end

    # -

    # -

      def number_of_lines_after_engaging_replacement_
        _all_lines_after_having_engaged_replacement.length
      end

      def expect_atoms_after_having_replaced_for_Nth_line_ d

        _ = _all_lines_after_having_engaged_replacement
        _line_throughput = _.fetch d

        begin_expect_atoms_for_ _line_throughput.a
        NIL_
      end

    # -
  end
end
