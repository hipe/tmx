module Skylab::Brazen

  module CollectionAdapters::GitConfig

    class Magnetics::EntityCollection_via_Document  # :[#028].

      # the document around which this is constructed is either immutable
      # or mutable. in the former case, operations that require a mutable
      # document can fail because it must first be converted (once) from
      # immutable to mutable..

      # file locking is explored beginning at [#028.3].

      # coverage currently starts at #cov2.1

      def initialize doc

        if doc.is_mutable
          _init_or_reinit_via_mutable_document doc
        else
          __init_via_immutable_document doc
        end
      end

      # -- read

      def build_facade cls, external_normal_name_symbol  # of section
        Facade___.new cls, external_normal_name_symbol, self
      end

      def to_section_stream
        document_.to_section_stream
      end

      def with_mutable_document listener, & do_this  # [tm]

        send @_with_mutable_doc, listener, & do_this
      end

      def description_under expag
        document_.description_under expag
      end

      def document_
        send @_document
      end

      # -- support: state changes from immutable to mutable

      def __with_mutable_doc_via_immutable_doc_initially listener, & do_this

        _idoc = remove_instance_variable :@_immutable_doc_instance

        _bur = _idoc.document_byte_upstream_reference

        mdoc = Here_::Mutable.parse_document_by do |o|
          o.byte_upstream_reference = _bur
          o.listener = listener
        end

        if mdoc
          _init_or_reinit_via_mutable_document mdoc
          send @_with_mutable_doc, listener, & do_this
        else
          # ..
          remove_instance_variable :@_with_mutable_doc
          remove_instance_variable :@_document
          freeze
          mdoc
        end
      end

      def _init_or_reinit_via_mutable_document doc

        @_with_mutable_doc = :_with_mutable_doc_as_is
        @_document = :_mutable_doc_instance
        @_mutable_doc_instance = doc ; nil
      end

      def __init_via_immutable_document doc

        @_document = :_immutable_doc_instance
        @_with_mutable_doc = :__with_mutable_doc_via_immutable_doc_initially
        @_immutable_doc_instance = doc ; nil
      end

      def _with_mutable_doc_as_is _listener
        yield @_mutable_doc_instance
      end

      def _mutable_doc_instance
        @_mutable_doc_instance  # hi.
      end

      def _immutable_doc_instance
        @_immutable_doc_instance  # hi.
      end

      def __duplicate_deeply_as_entity_collection_  # #testpoint only

        otr = self.class.allocate

        otr.instance_variable_set :@_mutable_doc_instance,
          @_mutable_doc_instance.DUPLICATE_DEEPLY_AS_MUTABLE_DOCUMENT_

        otr.instance_variable_set :@_document, @_document
        otr.instance_variable_set :@_with_mutable_doc, @_with_mutable_doc
        otr
      end

      # ==

      class Facade___

        def initialize cls, sym, ec
          @external_normal_name_symbol = sym  # of section
          @class = cls
          @entity_collection = ec
        end

        def update ent, & p
          _update_or_create p, ent do |o|
            o.be_update_not_create
          end
        end

        def create ent, & p
          _update_or_create p, ent do |o|
            o.be_create_not_update
          end
        end

        def _update_or_create p, ent

          Here_::Mutable::Magnetics::PersistEntity_via_Entity_and_Collection.call_by do |o|
            yield o
            o.entity = ent
            o.persist_these = ent.class::PERSIST_THESE  # for now, just a sketch
            o.facade = self
            o.listener = p
          end
        end

        def build_section_as_EC_facade_by__  # assume document is mutable
          @entity_collection.document_.sections.build_section_by_ do |o|
            yield o
            o.unsanitized_section_name_symbol = @external_normal_name_symbol
          end
        end

        def delete nat_key, & p

          # you've got to convert the document to a mutable document first
          # before you gather the the object ID's of sections to delete

          @entity_collection.with_mutable_document p do |doc|

            lu = lookup_section_ nat_key
            if lu.did_find
              _ary = doc.sections.delete_sections_via_sections_ [ lu.section ]
              _entity_via_section _ary.fetch 0  # meh
            else
              p.call :error, :expression, :component_not_found do |y|
                y << "cannot delete #{ lu.description_under self }"
                y << lu.to_one_line_of_further_information_under( self )
              end
              UNABLE_
            end
          end
        end

        def dereference nat_key
          ent = lookup_softly nat_key
          if ent
            ent
          else
            self._COVER_ME__entity_not_found_for_dereference__
            lookup_section_( nat_key ).xxx
          end
        end

        def lookup_softly nat_key
          sect = lookup_section_softly_ nat_key
          if sect
            _entity_via_section sect
          end
        end

        def lookup_section_softly_ nat_key  # #testpoint

          sym = @external_normal_name_symbol

          _to_every_section_stream.flush_until_detect do |sect|

            if sym == sect.external_normal_name_symbol
              nat_key == sect.subsection_string  # hi.
            end
          end
        end

        def to_stream_of_all_such_entities

          sym = @external_normal_name_symbol

          _to_every_section_stream.map_reduce_by do |sect|

            if sym == sect.external_normal_name_symbol
              _entity_via_section sect
            end
          end
        end

        def procure nat_key, & p

          lu = lookup_section_ nat_key
          if lu.did_find
            _entity_via_section lu.section
          else
            p.call :error, :expression, :component_not_found do |y|
              y << "#{ lu.description_under self } not found"
              y << lu.to_one_line_of_further_information_under( self )
            end
            UNABLE_
          end
        end

        def lookup_section_ nat_key

          # like much of the lookup logic above, but gather metadata
          # while traversing the document for use in event emission.

          sym = @external_normal_name_symbol

          count_of_all_sections = 0
          count_of_relevant_sections = 0

          found = _to_every_section_stream.flush_until_detect do |sect|

            if sym == sect.external_normal_name_symbol
              if nat_key == sect.subsection_string  # hi.
                true
              else
                count_of_relevant_sections += 1
                count_of_all_sections += 1 ; false
              end
            else
              count_of_all_sections += 1 ; false
            end
          end

          if found
            FoundSection___.new found, nat_key, @external_normal_name_symbol
          else
            _buref = @entity_collection.document_.document_byte_upstream_reference
            DidNotFindSection___.new count_of_relevant_sections, nat_key,
              @external_normal_name_symbol, count_of_all_sections, _buref
          end
        end

        def _entity_via_section sect

          # (if ever we wanted to roll out a [#028.W.A] datamapper-like etc..)

          st = sect.assignments.to_stream_of_assignments

          @class.define do |o|
            o._natural_key_string_ = sect.subsection_string
            begin
              asmt = st.gets
              asmt || break
              o.send :"#{ asmt.external_normal_name_symbol }=", asmt.value
              redo
            end while above
          end
        end

        def _to_every_section_stream
          @entity_collection.document_.to_section_stream
        end

        attr_reader(
          :entity_collection,
          :external_normal_name_symbol,
        )

        def DUPLICATE_DEEPLY_AS_FACADE__AS__IMMUTABLE_MUTABLE__

          # *this* one is for when the receiver *is* such a subject as
          # described below, and we want to make a truly mutable deep
          # copy of it for use in a test case (i.e a mutating operation that
          # is testing success..)

          otr = _common_dup
          otr.instance_variable_set :@entity_collection,
            @entity_collection.__duplicate_deeply_as_entity_collection_
          otr
        end

        def DUPLICATE_DEEPLY_AS_FACADE__FOR__IMMUTABLE_MUTABLE__  # #testpoint only

          # ridiculous - an "immutable mutable" is a subject that is
          # prepared to undergo the beginning of a mutating operation, but
          # one that also "knows" this operation will fail, and hence the
          # subject can be actually immutable and re-used across tests..

          otr =  _common_dup
          ec = @entity_collection

          # confirm that the current EC is in "immutable" mode:
          ec.instance_variable_defined? :@_immutable_doc_instance or self._CHANGED?

          # make a plain old dup (you want every ivar), make it immutable:
          otr_ec = ec.dup
          otr_ec.with_mutable_document :_no_listener_BR_ do |doc|
            doc.sections  # eew, will need it. won't duplicate over to copies
            doc.freeze_as_mutable_document___
          end

          otr.instance_variable_set :@entity_collection, otr_ec
          otr.freeze
        end

        def _common_dup
          otr = self.class.allocate
          otr.instance_variable_set :@class, @class
          otr.instance_variable_set :@external_normal_name_symbol, @external_normal_name_symbol
          otr
        end
      end

      # ==

      DidOrDidNotFindSection__ = ::Class.new

      class DidNotFindSection___ < DidOrDidNotFindSection__

        def initialize dd, s, sym, d, buref
          @byte_upstream_reference = buref
          @count_of_relevant_sections = dd
          @count_of_all_sections = d
          super s, sym
        end

        def to_one_line_of_further_information_under expag

          dd = @count_of_relevant_sections ; d = @count_of_all_sections
          buref = @byte_upstream_reference  # if not trueish assume nil
          me = self

          expag.calculate do

            dsc = -> { buref and buref.description_under self }
            dash = -> { s = dsc[] and " - #{ s }" }
            in_ = -> { s = dsc[] and " in #{ s }" }

            if dd.zero?
              if d.zero?
                "document is empty#{ dash[] }"  # perhaps not technically true but effectively true
              else

                # (lends supplemental coverage to [#hu-008.1])

                simple_inflection do

                  # "none of the 10 sections was about shoes"
                  # "the only section was not about a shoe"
                  # "there are no sections so nothing was about shoes" (won't hit)

                  write_count_for_inflection d

                  _topic = indef me._describe_model_under_ self

                  _verb = no_double_negative :was

                  "#{ the_only } #{ n 'section' } #{ _verb } #{
                    }about #{ _topic }#{ in_[] }"
                end
              end
            else

              simple_inflection do

                write_count_for_inflection dd

                _eek = me._describe_model_under_ self

                "#{ the_only } #{ n _eek } #{ no_double_negative 'has' } #{
                  }this identifier#{ in_[] }"
              end
            end
          end
        end

        def did_find
          FALSE
        end
      end

      class FoundSection___ < DidOrDidNotFindSection__

        def initialize sect, s, sym
          @section = sect
          super s, sym
        end

        attr_reader :section

        def did_find
          TRUE
        end
      end

      class DidOrDidNotFindSection__

        def initialize s, sym
          @natural_key_string = s
          @external_normal_name_symbol = sym
          freeze
        end

        def description_under expag

          _nat = _describe_natural_key_string_under_ expag
          _hum = _describe_model_under_ expag

          "#{ _hum } #{ _nat }"
        end

        def _describe_model_under_ _expag
          @external_normal_name_symbol.id2name.gsub UNDERSCORE_, SPACE_  # meh
        end

        def _describe_natural_key_string_under_ _expag
          @natural_key_string.inspect  # meh
        end
      end

      # ==
      # ==
    end
  end
end
# #history: rewrite during proper birth of entity collection
