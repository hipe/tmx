module Skylab::Fields

  module CommonAssociationMetaAssociations_  # 1x (this lib only). exegesis in [#002]

    # -

      module EntityKillerModifiers

        module PrefixedModifiers

          def positive_nonzero_integer
            @parse_tree.must_be_integer_greater_than_or_equal_to_this 1
          end

          def non_negative_integer
            @parse_tree.must_be_integer_greater_than_or_equal_to_this 0
          end

          def required
            @parse_tree.be_required
          end

          def flag
            @parse_tree.be_flag
          end

          def glob
            @parse_tree.be_glob
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

          def argument_is_optional
            @parse_tree.have_argument_that_is_optional
          end

          def default
            x = @scanner.gets_one
            @parse_tree.will_default_by do |_ent|
              Common_::KnownKnown[ x ]
            end
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

    # -

    module ClassicMetaAttributes  # :[#002.H.3]

      # 18 of them at writing. these are what unified us to "attributes"

      # -- UI-level (the highest level here)

      def desc  # #cov2.9

        _desc_p = @_meta_argument_scanner_.gets_one

        @_association_.accept_description_proc__ _desc_p ; nil
      end

      # -- parameter arity
      #
      #    the fundamnetalest part of normalization, "high-level" because
      #    conceptually it happans after and outside of argument interpretetion
      #
      #    (there can be [#002.4] weirdness in how the requiredness check is effected)

      def required  # #cov2.10 - the newer addition to the pair
        @_association_interpreter_.index_statically_ :see_required
        @_association_.be_required__
      end

      def optional  # #cov2.1
        @_association_interpreter_.index_statically_ :see_optional
        @_association_.be_optional__
      end

      # -- defaulting is considered a higher-level nicety

      def default  # #cov2.8

        x = @_meta_argument_scanner_.gets_one
        if x.nil?
          self._COVER_ME_dont_use_nil_use_optional
        end

        @_association_.be_defaultant_by_value__ x
      end

      def default_proc  # #cov2.8

        _x = @_meta_argument_scanner_.gets_one

        @_association_.be_defaultant_by_( & _x )
      end

      # -- custom value interpretation

      def known_known  # #cov2.1 like "monadic" but wraps the value in knownness

        @_association_.argument_value_producer_by_ do
          -> do
            Common_::KnownKnown[ argument_scanner_.gets_one ]
          end
        end
      end

      # -- common value interpretation: argument arity (more args down to less args)

      def singular_of  # #cov2.1 when you have a glob field, exposes a modifier to write ony one item to it

        sym = @_meta_argument_scanner_.gets_one

        ca = @_association_

        ca.argument_value_producer_by_ do
          -> do
            [ argument_scanner_.gets_one ]
          end
        end

        ca.argument_value_consumer_by_ do |_atr|

          -> x, _p do
            asc = @_normalization_.association_index.read_association_ sym
            mutate_for_redirect_ x, asc
            asc.flush_DSL_for_interpretation_ self  # result is kp
          end
        end
      end

      def plural  # #COVER-ME [sa]

        @_association_.argument_arity = :zero_or_more
      end

      def list  # #cov2.2  make oldschool DSL-like writer

        @_association_interpreter_.entity_class_enhancer_by_ do |asc|

          -> mod do
            mod.send :define_method, asc.name_symbol do |x|
              ivar = asc.as_ivar
              if instance_variable_defined? ivar
                a = instance_variable_get ivar
              end
              if a
                a.push x
              else
                instance_variable_set ivar, [ x ]
              end
              NIL_  # because basic object
            end
          end
        end
      end

      # ~

      def flag  # #cov2.1. an interpretation whose value is always `true`

        @_association_.argument_value_producer_by_ do
          NILADIC_TRUTH_
        end

        @_association_.argument_arity = :zero
      end

      def flag_of  # #cov2.1 says "use this other association, but give it `true`"

        sym = @_meta_argument_scanner_.gets_one

        @_association_.argument_value_producer_by_ do
          NILADIC_TRUTH_
        end

        @_association_.argument_value_consumer_by_ do |_atr|

          -> x, _p do

            # "flag of" must have the *full* pipeline of the referrant -
            # read *and* write.

            asc = @_normalization_.association_index.read_association_ sym
            mutate_for_redirect_ x, asc
            asc.flush_DSL_for_interpretation_ self  # result is kp
          end
        end
      end

      # -- in "association theory" (maybe near [#017]) enumeration is one of the fundamnetalest

      def boolean  # #cov2.4 for ancient DSL-controller. see also `flag`
        Home_::CommonMetaAssociations::Boolean::Parse[ @_association_interpreter_ ]
      end

      def enum  # #cov2.3
        Home_::CommonMetaAssociations::Enum::Parse[ @_association_interpreter_ ]
      end

      # -- lower-level, governs interaction with value store

      def ivar  # #cov2.5 for indicating a non-normal ivar to use for storage
        @_association_.as_ivar = @_meta_argument_scanner_.gets_one
      end

      # -- delegate the work (component, two kinds of interpreter method) & possible support

      def component  # #cov2.6 #experimental:

        # avoid dependency on [ac] for now. this is a microscopic ersatz of
        # it, to let the work form its own upgrade path..

        @_association_.argument_value_producer_by_ do |asc|

          m = :"__#{ asc.name_symbol }__component_association"

          -> do
            _ca = @_normalization_.entity.send m  # no yield for now - if you need it, use [ac]
            _ca.interpret_component argument_scanner_, @_association_
          end
        end
      end

      def custom_interpreter_method  # #cov2.5

        # a full replacement for the entire interpretation process of
        # interpreting the attribute value.

        # created to facilitate custom aliases [hu].
        # also bolsters readability for hybrid actors.

        @_association_.argument_interpreter_by_ do |asc|

          m = Attr_writer_method_name_[ asc.name_symbol ]

          -> do
            ent = @_normalization_.entity

            if ! ent.instance_variable_defined? ARGUMENT_SCANNER_IVAR_
              ent.instance_variable_set ARGUMENT_SCANNER_IVAR_, argument_scanner_
              yes = true
            end

            x = ent.send m

            yes and ent.remove_instance_variable ARGUMENT_SCANNER_IVAR_

            ACHIEVED_ == x ? KEEP_PARSING_ : raise( ::ArgumentError, Say_expected_achieved__[ x ] )
          end
        end
      end

      def custom_interpreter_method_of  # #cov2.5

        m = @_meta_argument_scanner_.gets_one

        @_association_.argument_interpreter_by_ do |_atr|

          -> do
            x = @_normalization_.entity.send m, argument_scanner_
            if ACHIEVED_ == x
              KEEP_PARSING_
            else
              raise ::ArgumentError, Say_expected_achieved__[ x ]
            end
          end
        end
      end

      Say_expected_achieved__ = -> x do
        "expected #{ ACHIEVED_ } had #{ Home_.lib_.basic::String.via_mixed x }"
      end

      # -- like delegators, but just "ride along"

      def hook  # #cov2.7

        @_association_interpreter_.entity_class_enhancer_by_ do |asc|

          ivar = asc.as_ivar ; k = asc.name_symbol

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

      # --
      # --

    end  # classic etc
  end
end

# #tombstone: we broke out ANCIENT meta-params DSL at #spot-3
# #tombstone: DSL atom
