module Skylab::DocTest

  module OutputAdapters_::Quickie

    class ViewControllers_::Starter

      DESC_ETC___ = '[ymh] your description here - your desription here'

      TEMPLATE_FILE___ = '_starter.tmpl'

      class << self
        alias_method :via_choices, :new
        undef_method :new
      end  # >>

      def initialize cx
        @_choices = cx
      end

      def some_original_test_line_stream__

        t = @_choices.load_template_for TEMPLATE_FILE___

        t.set_simple_template_variable(
          __description_bytes_placeholder,
          :describe_description_bytes,
        )

        t.set_simple_template_variable(
          'YourModuleHere',
          :home_module_string_from_top,
        )

        t.set_simple_template_variable(
          "require_relative 'test-support'",
          :require_something,
        )

        t.flush_to_line_stream
      end

      define_method :__description_bytes_placeholder, ( Lazy_.call do
        DESC_ETC___.inspect
      end )
    end
  end
end
# #tombstone: '_base' and '_body' templates subsumed into '_starter'
