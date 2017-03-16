module Skylab::Fields

  class Attributes

    class N_Meta_Attribute < Common_::SimpleModel

      # (the document that probably once described this work is currently at [#ba-013] and should move here.)

      # what this seems to be is an "earnest" attempt to distill what
      # "N-meta" association have (in their construction, at least) in
      # common, whether it's a business attribute or a fixed meta-
      # association, or maybe even a meta-meta-association (not sure, there.).
      #

      # -
        def initialize
          yield self
          @N_plus_one_interpreter_by ||= N_plus_one_interpreter_by___
          # can't freeze because #spot-1-1
        end

        def meta_associations_class= x
          @__meta_associations_class_ = x
        end

        attr_writer(
          :association_class,
          :indexing_callbacks,
          :N_plus_one_interpreter_by,
          :finish_association_by,
        )

        def build_and_process_association__ k, x  # AS PROTOTYPE
          dup.flush_for_build_and_process_association_ k, x
        end

        def flush_for_build_and_process_association_ k, x

          remove_instance_variable( :@association_class ).new k do |asc|

            @current_association_ = asc
          @_name_symbol = k

          if x
            scn = Common_::Scanner.via_array ::Array.try_convert( x ) || [ x ]
            @argument_scanner_for_current_association_ = scn

              p = @N_plus_one_interpreter_by[ self ]
            begin
              p[ scn.gets_one ]
            end until scn.no_unparsed_exists
          end

            @finish_association_by[ self ]
            NIL
          end
        end

      # -- look like a parse (..)

      def as_normalization_write_via_association_ x, asc
          @current_association_.instance_variable_set asc.as_ivar, x
        NIL
      end

      # -- exposures

      def add_methods_definer_by_ & atr_p

        index_statically_ :method_definers
        @current_association_.__add_methods_definer atr_p ; nil
      end

      def __index_customly meta_k
          @indexing_callbacks.add_to_the_custom_index_ @_name_symbol, meta_k
      end

      def index_statically_ meta_k
          @indexing_callbacks.add_to_the_static_index_ @_name_symbol, meta_k
      end

        attr_reader(
          :argument_scanner_for_current_association_,
          :current_association_,
          :__meta_associations_class_,
        )
      # -

    _SANITY_RX = /\A_/  # for now - catch typos & API mismatches

    when_etc = nil

      N_plus_one_interpreter_by___ = -> build do

        ma_cls = build.__meta_associations_class_

      mattrs = ma_cls.new build

      -> k do

        if ma_cls.method_defined? k
          mattrs.__send__ k
          NIL_

        elsif _SANITY_RX =~ k
          build.__index_customly k
          NIL_

        else
          when_etc[ k, ma_cls ]
        end
      end
    end

    when_etc = -> k, ma_cls do

      _m_a = ma_cls.instance_methods false

      _nf = Common_::Name.via_variegated_symbol :meta_association

      _ev = Home_::MetaAttributes::Enum::Build_extra_value_event.call(
        k, _m_a, _nf )

      raise _ev.to_exception
    end

    # ==
    # ==

    end
  end
end
# #pending-rename: `to N_MetaAttributeInterpreter`
