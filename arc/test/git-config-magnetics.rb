# frozen_string_literal: true

module Skylab::Arc::TestSupport

  module Git_Config_Magnetics

    def self.[] tcc
      tcc.include self
    end

    Lazy_ = Home_::Lazy_

    define_singleton_method :dangerous_memoize, TestSupport_::DANGEROUS_MEMOIZE

    dangerous_memoize :mutable_config_for_story_A_ do

      _MC_CGM '050-whiteboard-story-A.cfg'
    end

    dangerous_memoize :mutable_config_for_story_B_ do

      _MC_CGM '070-story-B-before.cfg'
    end

    def _MC_CGM tail

      _path = ::File.join fixture_files_, tail

      _cfg = Home_.lib_.brazen_NOUVEAU::CollectionAdapters::GitConfig::Mutable.parse_document_by do |o|
        o.upstream_path = _path
        o.listener = nil  # hi.
      end

      _cfg  # hi. #todo
    end

    define_method :fixture_files_, ( Lazy_.call do
      ::File.join TS_.dir_path, 'fixture-files'
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

    #
    # magnet 500: unit of work stream
    #

    def want_squential_component_offsets_are_represented_ uow_st, exp_component_num
      Here_::Unit_of_Work_Stream_via_Spoof::VISITING_this_guy[ uow_st, exp_component_num ]
    end

    def unit_of_work_stream_via_spoof_ ** hh

      _five = Here_::Unit_of_Work_Stream_via_Spoof.call_by( ** hh, lib: self )
      product_of_magnetic_500_via_five_( * _five )
    end

    def product_of_magnetic_500_via_five_ d, _100, _200, _300, _400

      magnet_500_.call_by(
        capsulization: _400,
        one_two_three: [ _100, _200, _300 ],
        number_of_components: d,
      )
    end

    def magnet_500_
      _protected_magnetics_GFM::UnitOfWorkStream_via_Capsulization
    end

    #
    # magnet 400: capsulization
    #

    dangerous_memoize :product_of_magnetic_400_for_story_B_ do  # #coverpoint2.5

      # NOTE - hard to read at first: the first level of elements corresponds
      # to clusters. (2 elements so 2 clusters.)
      #
      # for the second level of elements, if the element is an `_static_associated__associated_offset_`,
      # the number next to it is an offset to an association (as described at
      # [#024.N] "why?"). if it's `_non_associated__number_of_fellows_` then the number is
      # simply a count of holes (i.e sections that are not associated, i.e
      # will be deleted).

      _ = product_of_magnetic_300_SPOOFED_(
        [
          [ :_static_associated__associated_offset_, 0 ],
          [ :_non_associated__number_of_fellows_, 2 ],
          [ :_static_associated__associated_offset_, 2 ],
          [ :_non_associated__number_of_fellows_, 1 ],
        ],
        [
          [ :_non_associated__number_of_fellows_, 1 ],
          [ :_static_associated__associated_offset_, 8 ],
          [ :_non_associated__number_of_fellows_, 1 ],
          [ :_static_associated__associated_offset_, 12 ],
          [ :_non_associated__number_of_fellows_, 1 ],
        ],
      )
      call_magnetic_400_ _
    end

    dangerous_memoize :product_of_magnetic_400_for_story_C_ do  # #coverpoint2.6
      _ = product_of_magnetic_300_SPOOFED_(
        [
          [ :_static_associated__associated_offset_, 66 ],
          [ :_non_associated__number_of_fellows_, 1 ],
        ],
        [
          [ :_non_associated__number_of_fellows_, 2 ],
        ],
        [
          [ :_non_associated__number_of_fellows_, 3 ],
        ],
        [
          [ :_non_associated__number_of_fellows_, 2 ],
        ],
        [
          [ :_non_associated__number_of_fellows_, 1 ],
          [ :_static_associated__associated_offset_, 99 ],
        ],
      )
      call_magnetic_400_ _
    end

    def call_magnetic_400_ big_a

      magnet_400_.call_by do |o|
        o.reallocation_schematic = big_a
      end
    end

    def magnet_400_
      _protected_magnetics_GFM::Capsulization_via_ReallocationSchematic
    end

    #
    # magnet 300: reallocation schematic
    #

    dangerous_memoize :product_of_magnetic_300_for_story_A_MOCKED_ do
      product_of_magnetic_300_SPOOFED_(
        [
          [ :_static_associated__associated_offset_, 2 ],
          [ :_static_associated__associated_offset_, 3 ],
        ],
        [
          [ :_non_associated__number_of_fellows_, 5 ],
        ],
        [
          [ :_static_associated__associated_offset_, 4 ],
          [ :_static_associated__associated_offset_, 5 ],
        ]
      )
    end

    dangerous_memoize :product_of_magnetic_300_for_story_B_ do

      _edi = product_of_magnetic_100_for_story_B_

      _pci = product_of_magnetic_200_for_story_B_  # pluralton component index (associated locator offset schematic)

      build_product_of_magnetic_300_ _pci, _edi
    end

    def build_product_of_magnetic_300_for_story_A_OF_PARTIALLY_MOCKED_SOURCES___

      #   - a call to real system diff is not mocked
      #   - the two indexes are mocked, but "guaranteed" to be OK at writing

      _100 = product_of_magnetic_100_for_story_A_MOCKED_

      _200 = product_of_magnetic_200_for_story_A_MOCKED_

      build_product_of_magnetic_300_ _200, _100
    end

    def build_product_of_magnetic_300_for_story_B__

      _100 = product_of_magnetic_100_for_story_B_

      _200 = product_of_magnetic_200_for_story_B_

      build_product_of_magnetic_300_ _200, _100
    end

    def build_product_of_magnetic_300_ pci, edi
      magnet_300_.call_by do |o|
        o.pluralton_components_index = pci
        o.existing_document_index = edi
      end
    end

    def product_of_magnetic_300_SPOOFED_ * clust_a
      magnet_300_.VIA_CONDENSED clust_a
    end

    def magnet_300_
      _protected_magnetics_GFM::ReallocationSchematic_via_TwoIndexes
    end

    #
    # magnet 200: pluralton components index
    #

    dangerous_memoize :product_of_magnetic_200_for_story_A_MOCKED_ do

      # don't go thru the liability of all that other undertaking, but
      # NOTE incur a different liabiliity

      _spoofed = product_of_magnetic_200_SPOOFED_HACKISHLY_(
        associated_schema: [[2, 3], [nil, 1, nil, nil, 0], [4, 5]],
        # the above integers are offsets of the below *line items*. they
        # are *not* component offsets. so they must be 0-N.

        associations_YUCK: -> o do
          # component offset, cluster offset, offset in cluster
          o[ 0, 1, 4 ]
          o[ 2, 1, 1 ]
          o[ 3, 0, 0 ]
          o[ 4, 0, 1 ]
          o[ 5, 2, 0 ]
          o[ 6, 2, 1 ]
        end,
        # YUCK: first column: component offsets. can be any positive integer
        # but must be in order. 2nd and 3rd column: cluster offset and offset
        # in cluster.
      )

      # _real = product_of_magnetic_200_for_story_A_

      _spoofed
    end

    def product_of_magnetic_200_SPOOFED_HACKISHLY_ ** hh

      _mod = magnet_200_
      _mod.VIA_CONDENSED( ** hh )
    end

    dangerous_memoize :product_of_magnetic_200_for_story_A_ do

      _edi = product_of_magnetic_100_for_story_A_
      _qc = qualified_component_for_story_A_
      _epi = mutable_indexer_for_story_A_
      _200_GCM _edi, _qc, _epi
    end

    dangerous_memoize :product_of_magnetic_200_for_story_B_ do

      _edi = product_of_magnetic_100_for_story_B_
      _qc = qualified_component_for_story_B_
      _epi = mutable_indexer_for_story_B_
      _200_GCM _edi, _qc, _epi
    end

    def _200_GCM edi, qc, epi

      _ = magnet_200_.call_by do |o|

        o.qualified_component = qc

        o.existing_document_index = edi

        o.entity_profile_indexer = epi

        o.listener = _listener_helpful_for_development_GCM
      end
    end

    def magnet_200_
      _protected_magnetics_GFM::PluraltonComponentsIndex_via_ExistingDocumentIndex
    end

    #
    # magnet 100: existing document index
    #

    dangerous_memoize :product_of_magnetic_100_for_story_A_MOCKED_ do

      # this saves us on the huge code liability of
      # maintaining a big document BUT

      # don't go thru the liability of all that other undertaking, but
      # NOTE incur a different liabiliity

      _mod = magnet_100_

      _these = [[1, 1], [2, 3, 3, 3, 4], [5, 6]]

      _spoofed = _mod.VIA_CONDENSED _these

      # _real = product_of_magnetic_100_for_story_A_
      # be sure to check that real equals spoofed whenever appropriate

      _spoofed
    end

    dangerous_memoize :product_of_magnetic_100_for_story_A_ do  # "product of magnetic 100" = existing document index

      _me = mutable_entity_for_story_A_
      _qc = qualified_component_for_story_A_
      _epi = mutable_indexer_for_story_A_

      _mag_100_GCM _me, _qc, _epi
    end

    dangerous_memoize :product_of_magnetic_100_for_story_B_ do

      _me = mutable_entity_for_story_B_
      _qc = qualified_component_for_story_B_
      _epi = mutable_indexer_for_story_B_

      _mag_100_GCM _me, _qc, _epi
    end

    def _mag_100_GCM me, qc, epi

      ugh = qc.name.as_lowercase_with_underscores_string
      # #todo - something's not right when your association has all caps..

      _sym = ugh.downcase.intern

      magnet_100_.call_by do |o|
        o.mutable_entity = me
        o.component_association_name_symbol = _sym
        o.entity_profile_indexer = epi

        o.listener = _listener_helpful_for_development_GCM  # (see)
      end
    end

    dangerous_memoize :mutable_entity_for_story_A_ do
      _ME_CGM :mutable_config_for_story_A_
    end

    dangerous_memoize :mutable_entity_for_story_B_ do
      _ME_CGM :mutable_config_for_story_B_
    end

    def _ME_CGM m
      _mc = send m
      build_mutable_entity_by_ do |o|
        o._config_for_write_ = _mc
      end
    end

    dangerous_memoize :mutable_indexer_for_story_A_ do
      _EPI_GCM
    end

    dangerous_memoize :mutable_indexer_for_story_B_ do
      _EPI_GCM
    end

    def _EPI_GCM
      Home_::GitConfigMagnetics_::EntityProfileIndexer.new  # should be 1 of 2 when all is dnne
    end

    def magnet_100_
      _protected_magnetics_GFM::ExistingDocumentIndex_via_EntityProfileIndexer
    end

    #
    # support
    #

    def build_mutable_entity_by_ & p
      MutableEntity.define( & p )
    end

    def _listener_helpful_for_development_GCM

      # for many of the magnetics, if we don't set the listener to anyting
      # it triggers quite a few warnings.
      # although setting it to the below can be useful for development,
      # is fail behavior is not covered per se

      Home_::Magnetics::QualifiedComponent_via_Value_and_Association::Listener_that_raises_exceptions_
    end

    def _protected_magnetics_GFM
      These_magnetics__[]
    end

    These_magnetics__ = -> do
      Home_::GitConfigMagnetics_
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

      end

      class PhysicalObject < Same_

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

    Here_ = self

    # ==
    # ==
  end
end
# #pending-rename: branch down, probably
# #born (was stashed for ~6 months)
