module Skylab::BeautySalon

  module CrazyTownReportMagnetics_
    Autoloader_[ self ]
  end

    # ==

    class CrazyTownReportMagnetics_::Index_via_ReportClass

      def initialize rc

        @all_formals = Home_::Models_::CrazyTown::Shared_properties[]

        @does_need_listener = false
        @does_need_named_listeners = false

        @report_class = rc
        execute
      end

      def execute
        cls = @report_class
        MAP_THING___.each_pair do |write_m, m|
          cls.method_defined? write_m or next
          send m
        end
        remove_instance_variable :@all_formals
        remove_instance_variable :@report_class
        freeze
      end

      def __will_produce_file_path_upstream_resources
        @involves_path_upstream = true
        _add_formal_parameter :file
        _add_formal_parameter :files_file
        _add_formal_parameter :corpus_step
        _add_formal_parameter :macro
        _add_formal_parameter :whole_word_filter
      end

      def __add_the_code_selector_formal_parameter
        @takes_code_selector = true
        _add_formal_parameter :code_selector
      end

      def __add_the_replacement_function_formal_parameter
        @takes_replacement_function = true
        _add_formal_parameter :replacement_function
      end

      def __thing_for_named_listeners
        @does_need_named_listeners = true
      end

      def __thing_for_listener
        @does_need_listener = true
      end

      def _add_formal_parameter sym
        ( @add_these_formals ||= [] ).push @all_formals.fetch sym ; nil
      end

      attr_reader(
        :add_these_formals,
        :does_need_listener,
        :does_need_named_listeners,
        :involves_path_upstream,
        :takes_code_selector,
        :takes_replacement_function,
      )
    end

    MAP_THING___ = {
      :code_selector= => :__add_the_code_selector_formal_parameter,
      :file_path_upstream_resources= => :__will_produce_file_path_upstream_resources,
      :listener= => :__thing_for_listener,
      :named_listeners= => :__thing_for_named_listeners,
      :replacement_function= => :__add_the_replacement_function_formal_parameter,
      # :#spot1.1
    }

    # ==

    # ==
    # ==
  # -
end
# #history-A.1: full rewrite: used to be front pipeliner. now general small magnetics
#   # #tombstone: take away feature not yet in current CLI - help screen truncation
# #born
