# frozen_string_literal: true

module Skylab::Arc::TestSupport

  module Git_Config_Magnetics

    def self.[] tcc
      tcc.include self
    end

    Lazy_ = Home_::Lazy_

    define_method :mutable_config_A_, ( Lazy_.call do

      fixture_files_ = ::File.join TS_.dir_path, 'fixture-files'

      _path = ::File.join fixture_files_, '050-whiteboard-story-A.cfg'

      _cfg = Home_.lib_.brazen_NOUVEAU::CollectionAdapters::GitConfig::Mutable.parse_document_by do |o|
        o.upstream_path = _path
        o.listener = nil  # hi.
      end

      _cfg  # hi. #todo
    end )

    define_method :qualified_component_for_story_A_, ( Lazy_.call do

      a = []
      mdls = Models

      # (from whiteboard, these accord along #coverpoint2.3)
      #
      #     D  Q  C  A  A'  E  F

      a.push( mdls::PhysicalObject.define do |o|  # D
        o.category_symbol = :troll_doll
      end )

      a.push( mdls::PerishableFoodItem.define do |o|  # Q
        o.identifying_description = "this is food item Q"
      end )

      a.push( mdls::PhysicalObject.define do |o|  # C
        o.category_symbol = :fidget_spinner
      end )

      a.push( mdls::PerishableFoodItem.define do |o|  # A
        o.category_symbol = :greek_yogurt
        o.identifying_description = "kiwi flavored"
      end )

      a.push( mdls::PerishableFoodItem.define do |o|  # A'
        o.category_symbol = :greek_yogurt
        o.identifying_description = "kiwi flavored"
      end )

      a.push( mdls::PerishableFoodItem.define do |o|  # E
        o.category_symbol = :banana
      end )

      a.push( mdls::PerishableFoodItem.define do |o|  # F
        o.category_symbol = :cliff_bar
      end )

      _name = Common_::Name.via_lowercase_with_underscores_symbol :things_in_my_bag

      Common_::QualifiedKnownKnown.via_value_and_association a, _name
    end )

    def build_mutable_entity_by_ & p
      MutableEntity.define( & p )
    end

    class MutableEntity < Common_::SimpleModel

      # typically this is some business entity (in [cu] at present it's Survey)

      attr_accessor(
        :_config_for_write_,
      )

      def _models_feature_branch_
        Models.boxxy_module_as_feature_branch  # :#here2
      end
    end

    Same_ = ::Class.new Common_::SimpleModel

    module Models

      class PerishableFoodItem < Same_

        def _xx_
        end
      end

      class PhysicalObject < Same_

        def _xx_
        end
      end

      Autoloader_[ self, :boxxy ]  # because #here2
    end

    class Same_ < Common_::SimpleModel

      class << self

        def define_via_persistable_primitive_name_value_pair_stream_by

          # starting around now (and replacing earlier work in [arc]), models
          # (i.e entity classes) that want to unmarshal in a generic, API-
          # friendly way must do so through a method with this name.
          #
          # (the name is a specialized form of the idiomatic and ubiquitous
          # `define` as used by SimpleModel.)
          #
          # (the mouthful "persistable primitive name value pair stream"
          # states unambiguously what the primary argument is to this method.)
          #
          # (here we use inheritance to achieve this same implementation
          # across different models.)
          #
          # the below implementation of this method leverages an adaptation
          # of this generic interface for unmarshaling to the "model model"
          # used by the subclasses of the subject: the new "simplicity"
          # model model.

          Home_::AssociationToolkit::Entity_by_Simplicity_via_PersistablePrimitiveNameValuePairStream.call_by do |o|
            yield o
            o.model_class = self
          end
        end

        def _name_symbol_

          # NOTE - this primitive structure is included in the [etc] to
          # *help* uniquely identify the (er) practical identity of your
          # entity within the context of the pluralton group. in particular,
          # adding this element to the tuple would help only for those cases
          # where two entities of different classes would have the same
          # constituency and same corresponding values (imaginable,
          # certainly). but note the below 'solution' will not work for all
          # imaginable collections of model classes (for example if you
          # had model classes `Foo::Baz` and `Bar::Baz`, or `IO` and `Io`
          # (yikes). with wild model class topolgoies, you may have to
          # sophisticate this accordingly.

          @___name_symbol ||= Common_::Name.via_module( self ).as_lowercase_with_underscores_symbol
        end
      end # >>

      TYPES = {
        identifying_description: :_string_,
      }

      attr_accessor(
        :category_symbol,
        :identifying_description,
      )

      def freeze

        # (assume this call is coming from SimpleModel)
        #
        # here's the clincher for entities that are part of a pluraton
        # group: they must expose a `_comparator_for_practical_equivalence_`
        # (composed only of atomic primitives and arrays (can be recursively))
        # that encompases the "practical identity" of the entity.
        #
        # (the reason this data compartmentalized into a dedicated data
        # member rather than somehow using the entity itself for this
        # purpose is exactly because :#code-example:[#024.H.2].)
        #
        # it is STRONGLY recommended that both your entities be frozen and
        # their [these] structures be frozen. (we don't want to think
        # about what would happen if hash code changes during the lifetime
        # of the entity.)

        _cls_sym = self.class._name_symbol_

        s = identifying_description
        arr = [ _cls_sym, category_symbol, s ]
        if s
          s.freeze
        end
        arr.freeze
        @_comparator_for_practical_equivalence_ = arr
        super
      end

      attr_reader(
        :_comparator_for_practical_equivalence_,
      )
    end

    # ==

    # ==
    # ==
  end
end
# #born (was stashed for ~6 months)
