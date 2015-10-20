module Skylab::Brazen
  # ->
    class Nodesque::Common_Properties < ::Module

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

      def has_name sym
        @_box[].has_name sym
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
    end

    class Cmn_Prps_Session___

      def initialize empty_module, extmod

        @_p = -> x_a, & edit_p do
          @_p = nil

          sess = Home_::Entity::Session.new
          sess.arglist = x_a
          sess.block = edit_p
          sess.client = empty_module
          sess.extmod = extmod
          sess.execute
        end
      end

      def edit_common_properties_module * a, & edit_p

        @_p[ a, & edit_p ]
      end
    end
    # <-
end
