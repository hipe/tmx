module Skylab::TestSupport

  class MockModule < ::BasicObject

    # define a mock module in terms of what methods and constants it
    # (mockedly) "has" and what methods (both kinds) and constants it
    # expects to have defined on it.

    # ordinarily (when not frozen), such a mock module will confirm each
    # such operation performed on it against its recording of expected
    # operations, throwing an exception when reality strays from what is
    # expected. this mode of operation requires that you cal `finish` at
    # the end of your test so the subject can complain about any
    # lingering expected but unexecuted operations.

    # alternatively, in "frozen" mode these mutating operations are not
    # "spent" when they are received (so do not call `finish` on frozen
    # subjects). frozen subjects are for when you need such modules as
    # collaborators but their state is not the focus of your test.

    # no coverage. being frontiered by coverage for quickie.
    # spiritually related to [#ba-048] "module & class creator"

    class << self
      def define
        o = new
        o.__will_be_frozen
        yield o
        o
      end
    end  # >>

    # -

      def initialize
        @_be_frozen = false
        @_via_category = {}
      end

      def __will_be_frozen
        @_be_frozen = true ; nil
      end

      def have_const_not_defined sym
        _add_expectation_of_read false, sym, :_const_
      end

      def have_method_not_defined sym
        _add_expectation_of_read false, sym, :_method_
      end

      def have_const_defined sym
        _add_expectation_of_read true, sym, :_const_
      end

      def have_method_defined sym
        _add_expectation_of_read true, sym, :_method_
      end

      def want_to_have_singleton_method_defined sym
        _add_expectation_of_write sym, :_singleton_method_
      end

      def want_to_have_method_defined sym
        _add_expectation_of_write sym, :_method_
      end

      def _add_expectation_of_read yn, sym, cat
        ( ( @_via_category[ cat ] ||= {} )[ :_read_ ] ||= {} )[ sym ] =
          YesOrNo___.new( yn, @_be_frozen )
        MY_NIL_
      end

      def _add_expectation_of_write sym, cat
        ( ( @_via_category[ cat ] ||= {} )[ :_write_ ] ||= {} )[ sym ] =
          FrozenOrNot___.new( @_be_frozen )
        MY_NIL_
      end

      # - use

      def send m, m_, * _
        case m
        when :define_method
          _process_write :_method_, m_
        when :define_singleton_method
          _process_write :_singleton_method_, m_
        else
          ::Kernel.raise ::NameError, m
        end
      end

      def const_defined? const, _=nil
        _process_read :_const_, const
      end

      def method_defined? m
        _process_read :_method_, m
      end

      def _process_write cat, sym
        h = @_via_category.fetch( cat ).fetch :_write_
        record = h.fetch sym
        unless record.is_frozen
          h.delete sym
        end
        MY_NIL_
      end

      def _process_read cat, sym
        h = @_via_category.fetch( cat ).fetch :_read_
        record = h.fetch sym
        x = record.yes_not_no
        unless record.is_frozen
          h.delete sym
        end
        x
      end

      def finish  # assume no records are frozen
        @_via_category.each_pair do |cat, via_verb|
          via_verb.each_pair do |read_or_write, via_key|
            via_key.each_pair do |key, _record|
              ::Kernel.fail "never happened: #{ read_or_write } #{ cat } '#{ key }'"
            end
          end
        end
        MY_NIL_
      end

    # -

    # ==

    FrozenOrNot___ = ::Struct.new :is_frozen
    YesOrNo___ = ::Struct.new :yes_not_no, :is_frozen

    # ==

    MY_NIL_ = nil  # platfrom `NIL` (the constant, not they keyword) is
      # defined in `::Object`, which `::BasicObject` does not include.
      # (we perfer the const to the keyword for one reason.)

    # ==
  end
end
# #born
