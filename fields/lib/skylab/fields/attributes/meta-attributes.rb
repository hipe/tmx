module Skylab::Fields

  class Attributes

    class MetaAttributes < ::BasicObject  # 1x (this lib only). [#009]..

      # ==

      module EntityKillerModifiers

        module PrefixedModifiers

          def required
            @parse_tree.become_required
          end

          def flag
            @parse_tree.become_flag
          end

          def glob
            @parse_tree.become_glob
          end

          def property
            @parse_tree.accept_name_symbol @scanner.gets_one
            @parser.transition_from_prefix_to_postfix
          end
        end

        module PostfixedModifiers

          def description
            @parse_tree.will_describe_by_this @scanner.gets_one
          end

          def must_be_integer_greater_than_or_equal_to
            @parse_tree.must_be_integer_greater_than_or_equal_to_this @scanner.gets_one
          end

          def default_by
            @parse_tree.will_default_by( & @scanner.gets_one )
          end

          def normalize_by
            @parse_tree.will_normalize_by( & @scanner.gets_one )
          end

          def argument_moniker
            @parse_tree.receive_argument_moniker @scanner.gets_one
          end
        end
      end

      # ==

      def initialize build
        @_ = build
      end

      # -- the 17 default meta-attributes in alphabetical order.

      def boolean  # for ancient DSL-controller. see also `flag`

        Home_::MetaAttributes::Boolean::Parse[ @_ ]
      end

      def component  # #experimental:
        # avoid dependency on [ac] for now. this is a microscopic ersatz of
        # it, to let the work form its own upgrade path..

        @_.current_association_.reader_by_ do |atr|

          m = :"__#{ atr.name_symbol }__component_association"

          -> do
            _ca = entity.send m  # no yield for now - if you need it, use [ac]
            _ca.interpret_component argument_scanner, current_association
          end
        end
      end

      # (above is :#spot-1-4 an example of this DSL)

      def custom_interpreter_method

        # created to facilitate custom aliases [hu].
        # also bolsters readability for hybrid actors.

        @_.current_association_.will_interpret_by_ do |atr|

          Oldschool_custom_interpreter_as___[ Classic_writer_method_[ atr.name_symbol ] ]
        end
      end

      def custom_interpreter_method_of

        m = @_.argument_scanner_for_current_association_.gets_one

        @_.current_association_.will_interpret_by_ do |_atr|

          Newschool_custom_interpreter_as___[ m ]
        end
      end

      Newschool_custom_interpreter_as___ = -> m do

        -> do
          x = entity.send m, argument_scanner
          if ACHIEVED_ == x
            KEEP_PARSING_
          else
            raise ::ArgumentError, Say_expected_achieved__[ x ]
          end
        end
      end

      Oldschool_custom_interpreter_as___ = -> m do

        -> do

          ent = entity

          if ! ent.instance_variable_defined? ARGUMENT_SCANNER_IVAR_
            ent.instance_variable_set ARGUMENT_SCANNER_IVAR_, argument_scanner
            did = true
          end

          x = ent.send m

          if did
            ent.remove_instance_variable ARGUMENT_SCANNER_IVAR_
          end

          if ACHIEVED_ == x
            KEEP_PARSING_
          else
            raise ::ArgumentError, Say_expected_achieved__[ x ]
          end
        end
      end

      Say_expected_achieved__ = -> x do
        "expected #{ ACHIEVED_ } had #{ Home_.lib_.basic::String.via_mixed x }"
      end

      def default

        x = @_.argument_scanner_for_current_association_.gets_one
        if x.nil?
          self._COVER_ME_dont_use_nil_use_optional
        end

        @_.current_association_.be_defaultant_by_value__ x
      end

      def default_proc

        _x = @_.argument_scanner_for_current_association_.gets_one

        @_.current_association_.be_defaultant_by_( & _x )
      end

      def desc

        _desc_p = @_.argument_scanner_for_current_association_.gets_one

        @_.current_association_.accept_description_proc__ _desc_p ; nil
      end

      def enum
        Home_::MetaAttributes::Enum::Parse[ @_ ]
      end

      def flag

        ca = @_.current_association_

        ca.argument_arity = :zero

        ca.reader_by_ do
          NILADIC_TRUTH_
        end
      end

      def flag_of

        sym = @_.argument_scanner_for_current_association_.gets_one
        ca = @_.current_association_

        ca.reader_by_ do
          NILADIC_TRUTH_
        end

        ca.writer_by_ do |_atr|

          -> x, _oes_p do

            # "flag of" must have the *full* pipeline of the referrant -
            # read *and* write.

            asc = association_index.read_association_ sym
            mutate_for_redirect_ x, asc
            asc.flush_DSL_for_interpretation_ self  # result is kp
          end
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
        @_.current_association_.as_ivar = @_.argument_scanner_for_current_association_.gets_one
      end

      def known_known

        @_.current_association_.reader_by_ do
          -> do
            Common_::Known_Known[ argument_scanner.gets_one ]
          end
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
        @_.index_statically_ :see_optional
        @_.current_association_.be_optional__
      end

      def required
        @_.index_statically_ :see_required
        @_.current_association_.be_required__
      end

      def plural  # #experimental - ..

        @_.current_association_.argument_arity = :zero_or_more
      end

      def singular_of

        sym = @_.argument_scanner_for_current_association_.gets_one

        ca = @_.current_association_

        ca.reader_by_ do
          -> do
            [ argument_scanner.gets_one ]
          end
        end

        ca.writer_by_ do |_atr|

          -> x, _oes_p do
            asc = association_index.read_association_ sym
            mutate_for_redirect_ x, asc
            asc.flush_DSL_for_interpretation_ self  # result is kp
          end
        end
      end
    end  # meta-attributes
  end  # attributes
end  # fields

# #tombstone: we broke out ANCIENT meta-params DSL at #spot-3
# #tombstone: DSL atom
