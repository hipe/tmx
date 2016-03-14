module Skylab::Fields

  class Attributes

    class MetaAttributes < ::BasicObject  # 1x (this lib only). [#009]..

      def initialize build
        @_ = build
      end

      # -- the 14 default meta-attributes in alphabetical order.

      def boolean  # for ancient DSL-controller. see also `flag`

        Home_::MetaAttributes::Boolean::Parse[ @_ ]
      end

      def component  # #experimental:
        # avoid dependency on [ac] for now. this is a microscopic ersatz of
        # it, to let the work form its own upgrade path..

        ca = @_.current_attribute

        # ca.is_defined_component = true  # #todo-soon

        ca.read_by do

          _m = :"__#{ formal_attribute.name_symbol }__component_association"
          _c = session.send _m  # no yield for now - if you need it, use [ac]
          _c.interpret_component argument_stream, formal_attribute
        end
      end

      def custom_interpreter_method

        # created to facilitate custom aliases [hu].
        # also bolsters readability for hybrid actors.

        ca = @_.current_attribute

        # ca.is_defined_component = true  # #todo-soon

        ca.read_and_write_by do

          _m = Classic_writer_method_[ formal_attribute.name_symbol ]

          sess = session

          if ! sess.instance_variable_defined? ARG_STREAM_IVAR_
            sess.instance_variable_set ARG_STREAM_IVAR_, argument_stream
            did = true
          end

          x = sess.send _m

          if did
            sess.remove_instance_variable ARG_STREAM_IVAR_
          end

          if ACHIEVED_ == x
            KEEP_PARSING_
          else
            raise ::ArgumentError, Say_expected_achieved___[ x ]
          end
        end
      end

      Say_expected_achieved___ = -> x do
        "expected #{ ACHIEVED_ } had #{ Home_.lib_.basic::String.via_mixed x }"
      end

      def default

        x = @_.sexp_stream_for_current_attribute.gets_one
        if x.nil?
          self._COVER_ME_dont_use_nil_use_optional
        end

        @_.current_attribute.be_defaultant_by_value__ x

        @_.add_to_static_index_ :effectively_defaultants ; nil
      end

      def desc

        _desc_p = @_.sexp_stream_for_current_attribute.gets_one

        @_.current_attribute.accept_description_proc__ _desc_p ; nil
      end

      def enum
        Home_::MetaAttributes::Enum::Parse[ @_ ]
      end

      def flag
        @_.current_attribute.read_by do
          true
        end
      end

      def flag_of

        sym = @_.sexp_stream_for_current_attribute.gets_one
        ca = @_.current_attribute

        ca.read_by do
          true
        end

        ca.write_by do |x|

          # "flag of" must have the *full* pipeline of the referrant -
          # read *and* write.

          atr = index.lookup_attribute_ sym
          _mutate_for_redirect x, atr
          atr.read_and_write_ self  # result is kp
        end
      end

      def hook

        @_.add_methods_definer_by_ do |atr|

          ivar = atr.as_ivar ; k = atr.name_symbol

          -> mod do

            mod.module_exec do

              define_method :"on__#{ k }__" do | & p |
                instance_variable_set ivar, p ; nil
              end

              define_method :"receive__#{ k }__" do | * a, & p |
                _ = instance_variable_get( ivar )[ * a, & p ]
                _  # use with caution - coupling to callbacks can be ick
              end

              define_method :"__#{ k }__handler" do
                # (no by-name reader. enforce consistency)
                if instance_variable_defined? ivar
                  instance_variable_get ivar
                end
              end
            end
          end
        end
      end

      def ivar
        @_.current_attribute.as_ivar = @_.sexp_stream_for_current_attribute.gets_one
      end

      def known_known

        @_.current_attribute.read_by do
          Callback_::Known_Known[ argument_stream.gets_one ]
        end
      end

      def list

        @_.add_methods_definer_by_ do |atr|

          -> mod do
            mod.send :define_method, atr.name_symbol do |x|
              ivar = atr.as_ivar
              if instance_variable_defined? ivar
                a = instance_variable_get ivar
              end
              if a
                a.push x
              else
                instance_variable_set ivar, [ x ]
              end
              NIL_
            end
          end
        end
      end

      def optional

        @_.current_attribute.be_optional__
        @_.add_to_static_index_ :effectively_defaultants ; nil
      end

      def singular_of

        sym = @_.sexp_stream_for_current_attribute.gets_one

        ca = @_.current_attribute

        ca.read_by do
          [ argument_stream.gets_one ]
        end

        ca.write_by do |x|

          atr = index.lookup_attribute_ sym
          _mutate_for_redirect x, atr
          atr.read_and_write_ self  # result is kp
        end
      end
    end  # meta-attributes
  end  # attributes
end  # fields

# #tombstone: we broke out ANCIENT meta-params DSL at #spot-3
# #tombstone: DSL atom
