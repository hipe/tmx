module Skylab::Brazen::TestSupport

  module Collection_Adapters::Git_Config::Entity_Collection

    def self.[] tcc
      tcc.include self
    end

    # -

      # -- assertion

      define_singleton_method :dangerous_memoize, TestSupport_::DANGEROUS_MEMOIZE

      def build_hash_of_assignments_after_for_ hum_s, fac

        bx = Common_::Box.new  # tacit assertion of uniqueness of keys

        _sect = fac.lookup_section_softly_ hum_s

        st = _sect.assignments.to_stream_of_assignments
        begin
          asmt = st.gets
          asmt || break
          bx.add asmt.external_normal_name_symbol, asmt
          redo
        end while above
        bx.h_
      end

      # -- fixtures (memoized & not)

      def build_new_mutable_footwear_facade_
        footwear_facade_immutable_mutable_.DUPLICATE_DEEPLY_AS_FACADE__AS__IMMUTABLE_MUTABLE__
      end

      dangerous_memoize :footwear_facade_immutable_mutable_ do
        footwear_facade_immutable_.DUPLICATE_DEEPLY_AS_FACADE__FOR__IMMUTABLE_MUTABLE__  # see
      end

      dangerous_memoize :footwear_facade_immutable_ do
        entity_collection_one_immutable_.build_facade Footwear, :foot_wear
      end

      dangerous_memoize :jawn_jawn_facade_ do
        entity_collection_one_immutable_.build_facade :_NEVER_USED_br_, :jawn_jawn
      end

      dangerous_memoize :entity_collection_one_immutable_ do

        _path = entity_collection_one_path_

        _GitConfig = Git_config__[]

        _doc = _GitConfig.parse_document_by do |o|
          o.upstream_path = _path
        end

        _GitConfig::Magnetics::EntityCollection_via_Document.new( _doc ).freeze
      end

      def entity_collection_one_path_
        ::File.join Fixture_path_directory_[], 'file-001-clothing.cfg'
      end

      -> do
        s = "my favorite cons"
        s_ = "joggers"
        define_method :my_favorite_cons_ do s end
        define_method :joggers_ do s_ end
      end.call

      def footwear_class_with_persistence_info_
        FootwearWithPersisenceInfo
      end

      def footwear_class_
        Footwear
      end

      def expression_agent
        This_other_expression_agent_[]
      end
    # -

    # ==

    class FootwearWithPersisenceInfo < Common_::SimpleModel

      PERSIST_THESE = [
        # (keep this in alphabetical order because #spot1.1)
        :date_of_purchase,
        :main_color,
        :weight_in_ounces,
      ]

      attr_accessor(
        :_natural_key_string_,
        :date_of_purchase,
        :main_color,
        :weight_in_ounces,
      )
    end

    class Footwear < Common_::SimpleModel

      attr_accessor(
        :_natural_key_string_,
        :date_of_purchase,
        :flimbitty_bimbitty,  # used as a strange attribute elsewhere, not here
        :main_color,  # pass thru for elsewhere
      )
    end

    # ==

    Git_config__ = -> do
      Home_::CollectionAdapters::GitConfig
    end

    # ==
    # ==
  end
end
# #born.
