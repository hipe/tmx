require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] events - missing" do

    TS_[ self ]
    use :memoizer_methods
    use :event_failure_graph_expression

    context "(with no subject)" do

      shared_subject :event_ do

        new_with_reasons_ name_( :foo_bar ), name_( :quux_grault )
      end

      it "(uses \"invariant be\" form)" do  # :#coverpoint1.3

        _be_this_message = eql(
          "missing required attributes «prp: foo_bar» and «prp: quux_grault»\n" )

        event_message_as_string_.should _be_this_message
      end
    end

    context "(oh mah guh baybuh) (see [#036]/figure-1.dot)" do

      shared_subject :event_ do

        a = [ name_( :A ), name_( :B ) ]
        @_J = name_ :J
        @_G = __build_G
        a.push __build_D
        a.push __build_E
        remove_instance_variable :@_G
        new_with_reasons_array_ a
      end

      it "the toplevel attributes get aggregated (again)" do
        _(0) == "missing required attributes «prp: A» and «prp: B»\n" or fail
      end

      it "the toplevel branch nodes are aggregated, note the expression template" do
        _(1) == "must 'd' and 'e'\n" or fail
      end

      it "we descend one level and list all (one) missingattributes of that" do
        _(2) == "'d' is missing required attribute «prp: F».\n" or fail
      end

      it "it is 'd' that introduces 'g'" do
        _(3) == "to 'd', must 'g'\n" or fail
      end

      it "it is 'g' that introduces 'j'" do
        _(4) == "'g' is missing required attribute «prp: J».\n" or fail
      end

      it "'e' is free to reference attribute 'j' (that is descended already)" do
        _(5) == "'e' is missing required attributes «prp: H» and «prp: J».\n" or fail
      end

      it "'e' when referencing the visited branch 'g' says \"also\"" do
        _(6) == "to 'e', must also 'g'\n" or fail
      end

      def _ d
        _ary.fetch d
      end

      shared_subject :_ary do
        event_message_as_line_array_
      end

      def __build_D
        o = begin_stub_ :D
        o._add_reason name_ :F
        o._add_reason @_G
        o
      end

      def __build_E
        o = begin_stub_ :E
        o._add_reason @_G
        o._add_reason name_ :H
        o._add_reason @_J
        o
      end

      def __build_G
        o = begin_stub_ :G
        o._add_reason @_J
        o
      end
    end
  end
end
