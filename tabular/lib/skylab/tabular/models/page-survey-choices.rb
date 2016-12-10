module Skylab::Tabular

  module ThisOneExperiment___

    def self.[] cls

      class << cls
        alias_method :define, :new
        private :dup
        undef_method :new
      end

      cls.extend ModuleMethods___
      cls.include InstanceMethods___
      NIL
    end

    module ModuleMethods___

      def attr_writer_once_and_reader * k_a

        k_a.each do |k|

          ivar = :"@#{ k }"

          define_method :"#{ k }=" do |x|
            instance_variable_defined? ivar and self._SANITY__already_written__
            instance_variable_set ivar, x
          end

          attr_reader k
        end
        NIL
      end
    end

    module InstanceMethods___

      def initialize
        yield self
        freeze
      end

      def add_by k, & p
        send :"#{ k }=", p
      end
    end
  end

  class Models::PageSurveyChoices

    ThisOneExperiment___[ self ]

    def initialize
      super
      @page_size || self._MISSING_REQUIRED_ATTRIBUTE__page_size
    end

    attr_writer_once_and_reader(
      :field_observers_array,
      :field_surveyor,
      :hook_for_end_of_page,
      :hook_for_end_of_mixed_tuple_stream,
      :hook_for_special_headers_spot_in_first_page_ever,
      :page_size,
    )
  end
end
# #history: broke out of core when acquired box-like strictness
