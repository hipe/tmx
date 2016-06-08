module Skylab::Fields

  class Attributes

    N_Meta_Attribute = ::Module.new

    class N_Meta_Attribute::Build

      def initialize ma_cls, atr_cls
        @_attribute_class = atr_cls
        @meta_attributes_class = ma_cls
      end

      attr_writer(
        :attribute_services,
        :build_N_plus_one_interpreter,
        :finish_attribute,
      )

      def __build_and_process_attribute k, x  # AS PROTOTYPE
        dup.flush_for_build_and_process_attribute_ k, x
      end

      def flush_for_build_and_process_attribute_ k, x

        remove_instance_variable( :@_attribute_class ).new k do |atr|

          @current_attribute = atr
          @_name_symbol = k

          if x
            _ = ::Array.try_convert( x ) || [ x ]
            st = Common_::Polymorphic_Stream.via_array _
            @sexp_stream_for_current_attribute = st

            p = @build_N_plus_one_interpreter[ self ]
            begin
              p[ st.gets_one ]
            end until st.no_unparsed_exists
          end

          @finish_attribute[ self ]

          NIL_
        end
      end

      # -- look like a parse (..)

      def session
        @current_attribute
      end

      # -- exposures

      def add_methods_definer_by_ & atr_p

        add_to_static_index_ :method_definers
        @current_attribute.__add_methods_definer atr_p ; nil
      end

      def __add_to_custom_index meta_k
        @attribute_services.add_to_the_custom_index_ @_name_symbol, meta_k
      end

      def add_to_static_index_ meta_k
        @attribute_services.add_to_the_static_index_ @_name_symbol, meta_k
      end

      attr_reader(
        :current_attribute,
        :meta_attributes_class,
        :sexp_stream_for_current_attribute,
      )
    end

    _SANITY_RX = /\A_/  # for now - catch typos & API mismatches

    when_etc = nil

    N_Meta_Attribute::Common_build_N_plus_one_interpreter = -> build do

      ma_cls = build.meta_attributes_class
      mattrs = ma_cls.new build

      -> k do

        if ma_cls.method_defined? k
          mattrs.__send__ k
          NIL_

        elsif _SANITY_RX =~ k
          build.__add_to_custom_index k
          NIL_

        else
          when_etc[ k, ma_cls ]
        end
      end
    end

    when_etc = -> k, ma_cls do

      _m_a = ma_cls.instance_methods false

      _nf = Common_::Name.via_variegated_symbol :meta_attribute

      _ev = Home_::MetaAttributes::Enum::Build_extra_value_event.call(
        k, _m_a, _nf )

      raise _ev.to_exception
    end
  end
end
