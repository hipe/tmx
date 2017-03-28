module Skylab::Brazen

  class CommonAssociations < Common_::SimpleModel

    # this file is a #no-downtime-hybrid: we are splicing a brand new
    # munculus into it while keeping the legacy one fully functional and
    # intact..
    #
    # the new one is
    # more or less [#sl-129.3] three laws compliant.

    # -

      def initialize
        @_receive_injection = :__receive_injection
        @_box = Common_::Box.new
        yield self
        # no freeze because injection is loaded lazily
      end

      def add_association_by_definition_array sym, & p
        _add ByDefinitionArray__.new( p, sym )
        NIL
      end

      def _add ada
        @_box.add ada.name_symbol, MutableState__.new( ada, self )
        NIL
      end

      def property_grammatical_injection_by & p
        send @_receive_injection, p
      end

      def __receive_injection p
        remove_instance_variable :@_receive_injection
        @__injection_proc = p
        @_read_injection = :__read_injection_initially ; nil
      end

      # -- "read"

      def dereference sym
        @_box.fetch( sym ).__dereference_
      end

      def __association_injection_
        send @_read_injection
      end

      def __read_injection_initially
        @_read_injection = :__read_injection_subsequently
        inj = remove_instance_variable( :@__injection_proc ).call
        @__injection = inj
        inj
      end

      def __read_injection_subsequently
        @__injection
      end
    # -

    # ==

    class MutableState__

      def initialize ada, rsx
        @_dereference = :__dereference_initially
        @__adapter = ada
        @__resources = rsx
      end

      def __dereference_
        send @_dereference
      end

      def __dereference_initially
        _rsx = remove_instance_variable :@__resources
        x = remove_instance_variable( :@__adapter )._property_via_flush_ _rsx
        @__value = x
        @_dereference = :__dereference_subsequently
        freeze
        x
      end

      def __dereference_subsequently
        @__value
      end
    end

    # ==

    class ByDefinitionArray__

      def initialize p, sym
        @proc = p
        @name_symbol = sym
      end

      def _property_via_flush_ rsx

        _array = remove_instance_variable( :@proc ).call

        _inj = rsx.__association_injection_

        _asc = _inj.gets_one_item_via_scanner_fully Scanner_[ _array ]

        _asc  # hi. #todo
      end

      attr_reader(
        :name_symbol,
      )
    end

    # ==

    class LEGACY < ::Module

      def initialize entity_mod, & sess_p

        @_array = -> do
          a = @_box[].to_value_stream.to_a.freeze
          @_array = -> { a }
          a
        end

        @_box = -> do
          @_did_flush || @_flush[]
          bx = @_properties_p[]
          @_box = -> { bx }
          bx
        end

        @_properties_p = -> do
          self.properties
        end

        @_did_flush = false
        @_flush = -> do
          @_did_flush = true
          @_flush = nil
          __init_and_edit_entity_module entity_mod, & sess_p
          NIL_
        end
      end

      def has_key sym
        @_box[].has_key sym
      end

      def at * sym_a
        bx = @_box[]
        sym_a.map do | sym |
          bx.fetch sym
        end
      end

      def [] sym
        @_box[][ sym ]
      end

      def fetch sym, & p
        @_box[].fetch sym, & p
      end

      def array
        @_array[]
      end

      def to_value_stream
        @_box[].to_value_stream
      end

      def box
        @_box[]
      end

      def entity_property_class
        if ! @_did_flush
          @_flush[]
        end
        self::Property
      end

      def set_properties_proc & p  # if you are making a derivative collection
        @_did_flush = true
        @_flush = nil
        @_properties_p = p
        self
      end

      def __init_and_edit_entity_module entity_mod, & sess_p

        # [#xx-0011]
        _sess = Cmn_Prps_Session___.new self, entity_mod
        sess_p[ _sess ]
        NIL_
      end

    class Cmn_Prps_Session___

      def initialize empty_module, extmod

        @_p = -> x_a, & edit_p do
          @_p = nil

          Entity_lib_[].call_by do |sess|
            # -
          sess.arglist = x_a
          sess.block = edit_p
          sess.client = empty_module
          sess.extmod = extmod
            # -
          end
        end
      end

      def edit_common_properties_module * a, & edit_p

        @_p[ a, & edit_p ]
      end
    end
    end  # LEGACY

    # ==

    Scanner_ = -> a do
      Common_::Scanner.via_array a
    end

    # ==
    # ==
  end
end
