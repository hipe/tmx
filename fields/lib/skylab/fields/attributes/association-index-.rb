module Skylab::Fields

  class Attributes

    class AssociationIndex_

      # (see [#002.C] 'pertinent ideas around "attributes actors" and related')

      # -
        def initialize unparsed_h, ma_cls, atr_cls

          h = {} ; pool_proto = {}

          n_meta_prototype = Here_::N_Meta_Attribute::Build.new ma_cls, atr_cls
          o = n_meta_prototype  # #open [#015.1]

            o.attribute_services = self  # :#here-1

            o.build_N_plus_one_interpreter =
              Here_::N_Meta_Attribute::Common_build_N_plus_one_interpreter

            o.finish_attribute = -> build do
              # (this used to do things under #tombstone-D)  build.current_attribute
              NOTHING_
            end
          # -

          @_optional_or_required = nil
          @required_is_default_ = false
          @_custom_index = nil

          unparsed_h.each_pair do |k, x|
            asc = n_meta_prototype.build_and_process_attribute__ k, x
            k = asc.name_symbol
            pool_proto[ k ] = nil
            h[ k ] = asc
          end

          @_diminishing_pool_prototype = pool_proto.freeze
          @_hash = h.freeze
        end

        def AS_ASSOCIATION_INDEX_NORMALIZE_BY  # 1x [ta], covered here

          _wat = Here_::Normalization::Facility_C.call_by do |o|
            yield o
            o.association_index = self
          end

          _wat  # hi. #todo
        end

        # --

        def define_methods__ mod

          st = @method_definers.to_key_stream
          begin
            k = st.gets
            k || break
            @_hash.fetch( k ).deffers_.each do |p|
              p[ mod ]
            end
            redo
          end while above
          NIL
        end

        def is_X__ meta_k  # read-only
          ci = @_custom_index
          if ci
            bx = ci[ meta_k ]
            if bx
              bx.h_
            end
          end
        end

        def lookup_particular__ meta_k  # assumes some. read-only
          @_custom_index.fetch( meta_k ).a_
        end

        def association_array  # [ac]
          @___association_array ||= @_hash.values.freeze
        end

        def to_native_association_stream  # [ac] and 1x here.
          ea = @_hash.each_value
          Common_.stream do
            begin
              ea.next
            rescue ::StopIteration
            end
          end
        end

        def to_is_required_by  # [ac], 1x here

          # (implementation of [#002.4] is 1x redundant)

          yes = @required_is_default_
          -> asc do
            if asc.parameter_arity_is_known
              Is_required[ asc ]
            else
              yes  # if requiredness was not engaged, this is not required
            end
          end
        end

        def read_association_ k
          @_hash.fetch k
        end

        # --

        attr_reader(
          :_custom_index,
          :_diminishing_pool_prototype,
          :_hash,
          :required_is_default_,
        )
      # -

      # ==

      class BuildIndexBasedAssociationSource  # 1x

        def initialize
          @is_required_by = nil
          @__mutex = nil
          @_receive_etc = :__receive_etc_intially
        end

        def receive_association_index__ asc_idx

          remove_instance_variable :@__mutex

          if asc_idx

            asc_h = asc_idx._hash
            as_source_push_association_soft_reader_by_ do |k|
              asc_h[ k ]  # (hi.)
            end
          end

          @association_index_ = asc_idx
          NIL
        end

        def as_source_push_association_soft_reader_by_ & p
          send @_receive_etc, p
        end

        def __receive_etc_intially p
          @_association_soft_readerer = StackBasedAssociationSoftReader___.new
          @_receive_etc = :__receive_etc_normally
          send @_receive_etc, p
        end

        def __receive_etc_normally p
          @_association_soft_readerer.push_association_soft_reader_proc__ p
          NIL
        end

        attr_writer(
          :is_required_by,
        )

        # -- read

        def traverse_associations_checking_for_missing_requireds_only__ n11n

          # although covered by [fi], this special sub-algorithm is only used
          # by [ta]. as such we restrict its implementation code to only this
          # one model that uses it, until such time as it has broader utility.

          # under #tombstone-D this used to need less code because indexes.

          is_req = @is_required_by || @association_index_.to_is_required_by

          mixed_asc_st = to_native_association_stream

          vvs = n11n.valid_value_store

          begin  # (similar to n11n's counterpart loop except we never break)
            mixed_asc = mixed_asc_st.gets
            mixed_asc || break
            is_req[ mixed_asc ] || redo
            _x = vvs.read_softly_via_association mixed_asc
            _x.nil? || redo
            n11n.add_missing_required_MIXED_association_ mixed_asc
            redo
          end while above

          KEEP_PARSING_  # fall thru to client check if missing reqs were memo'd
        end

        def flush_injection_for_argument_traversal o, n11n

          scn = n11n.argument_scanner
          listener = n11n.listener

          o.argument_value_parser = -> native_asc do
            scn.advance_one  # #[#012.L.1] advance past the primary name
            native_asc.as_association_interpret_ n11n, & listener
          end

          asc_idx = @association_index_
          if asc_idx
            diminishing_pool = asc_idx._diminishing_pool_prototype.dup
            delete = diminishing_pool.method :delete
          else
            diminishing_pool = EMPTY_H_
            delete = MONADIC_EMPTINESS_
          end

          read = _association_soft_reader

          o.association_soft_reader = -> k do
            native_asc = read[ k ]
            if native_asc
              delete[ k ]
              native_asc
            end
          end

          o.extroverted_diminishing_pool = diminishing_pool

          NIL
        end

        def flush_injection_for_remaining_extroverted o, n11n

          o.extroverted_association_normalizer = -> native_asc do

            native_asc.as_association_normalize_in_place_ n11n
          end

          NIL
        end

        def flush_injection_for_full_extroverted_traversal o, n11n

          o.extroverted_association_stream = to_native_association_stream

          # NOTE #todo there is a potential bug here - per our new conception
          # of "extroversion" we don't apply ad-hoc normalization when doing
          # "normalize in place", but if such a normalization exists alongside
          # other meta-associations in associations in our extroverted index,
          # it will be effected below!

          o.extroverted_association_normalizer = -> native_asc do

            native_asc.as_association_normalize_in_place_ n11n
          end

          NIL
        end

        def to_native_association_stream  # [ta]

          asc_idx = @association_index_
          if ! asc_idx
            self._COVER_ME_AND_DESIGN_ME__how_to_stream_when_no_index
          end

          scn = Scanner_.call asc_idx._diminishing_pool_prototype.keys

          read = _association_soft_reader

          Common_.stream do
            unless scn.no_unparsed_exists
              read[ scn.gets_one ] || self._DEREFERENCE_FAILED
            end
          end
        end

        def to_is_required_by
          @association_index_.to_is_required_by
        end

        def _association_soft_reader
          send( @_association_soft_reader ||= :__assoc_soft_reader_initially )
        end

        def __assoc_soft_reader_initially

          p = remove_instance_variable(
            :@_association_soft_readerer ).__flush_to_soft_reader_
          @_association_soft_reader = :__assoc_soft_reader_subsquently
          @__assoc_soft_reader = p ; p
        end

        def __assoc_soft_reader_subsquently  # [ta]
          @__assoc_soft_reader
        end

        attr_reader(
          :association_index_,
        )

        def use_this_noun_lemma_to_mean_attribute
          USE_WHATEVER_IS_DEFAULT_
        end
      end

      # ==

      Writer_method_reader = -> cls do  # 1x. [fi] only

        -> name_sym do

          m = Classic_writer_method_[ name_sym ]

          if cls.private_method_defined? m
            m
          end
        end
      end

      # ==

      class StackBasedAssociationSoftReader___

        def initialize
          @_array = []
        end

        def push_association_soft_reader_proc__ p
          @_array.push p ; nil
        end

        def __flush_to_soft_reader_
          if 1 < @_array.length
            __when_tall_stack
          else
            remove_instance_variable( :@_array ).fetch 0
          end
        end

        def __when_tall_stack

          stack = remove_instance_variable :@_array
          top_d = stack.length - 1

          -> k do
            d = top_d
            begin
              asc = stack.fetch( d ).call k
              asc && break
              d.zero? && break
              d -= 1
              redo
            end while above
            asc
          end
        end
      end

      # ==

      # -
        # -- exposures for #here-1

        def add_to_the_custom_index_ k, meta_k

          _idx = ( @_custom_index ||= {} )
          _bx = _idx[ meta_k ] ||= Common_::Box.new
          _bx.add k, true  # so we can h[k] with a transparent h
        end

        def add_to_the_static_index_ asc_k, category_k
          send THESE__.fetch( category_k ), asc_k
        end

        THESE__ = {
          method_definers: :__add_to_method_definers_box,
          see_optional: :__see_optional,
          see_required: :__see_required,
        }

        def __see_optional _
          _see_parameter_arity :optional
        end

        def __see_required _
          _see_parameter_arity :required
        end

        def _see_parameter_arity sym
          existing = @_optional_or_required
          if existing
            if existing != sym
              self._COVER_ME__you_cannot_mixed_optional_and_required_in_one_definition_set__
            end
          else
            @_optional_or_required = sym
            @required_is_default_ = :optional == sym
          end
          NIL
        end

        def __add_to_method_definers_box asc_k
          ( @method_definers ||= Common_::Box.new ).add asc_k, nil
          NIL
        end
      # -

      class BoxBasedSimplifiedValidValueStore  # (this sees use at #spot-1-2)

        def initialize bx
          @_box = bx
        end

        def write_via_association x, asc
          @_box.add_or_replace(
            asc.name_symbol,
            -> { x },
            -> _ { x },
          )
          NIL
        end

        def read_softly_via_association asc  # [ta]
          @_box[ asc.name_symbol ]
        end

        def knows_value_for_association asc
          @_box.has_key asc.name_symbol
        end

        def dereference_association asc
          @_box.fetch asc.name_symbol
        end
      end

      # ==

      class MethodBasedAssociation  # 1x [fi]

        # (we don't subclass simplified name because we are one-off
        #  so we don't bother caching things lazily nor freezing.)

        # #open [#020] do we want to memoize these?

        def initialize m
          @__m = m
        end

        def as_association_interpret_ n11n, & x_p
          n11n.entity.send @__m, & x_p  # :#spot-1-5
        end
      end

      # ==

      EMPTY_H_ = {}.freeze

      # ==
    end
  end
end
# #tombstone-D: assimilating facility "C" meant simplifying away a lot
# #tombstone: facility "I" assimilated into the main normalization facililty
# #tombstone-B: used to use plain old mutable session
# #tombstone: `edit_actor_class`
