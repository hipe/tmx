module Skylab::Fields

  class Attributes

    class AssociationIndex_

      # -

        def initialize unparsed_h, ma_cls, atr_cls

          o = Build_Index_of_Definition___.new ma_cls, atr_cls

          h = {}
          unparsed_h.each_pair do |k, x|

            h[ k ] = o.__build_and_index_attribute k, x
          end

          @_custom_index = o.__release_thing_ding_one
          @static_index_ = o.__release_thing_ding_two

          @hash_ = h
        end

        def AS_INDEX_NORMALIZE_BY

          sidx = static_index_

          _wat = Here_::Normalization::Facility_C.call_by do |o|
            yield o
            o.non_required_name_symbols = sidx.non_required_name_symbols
            o.read_association_by = read_association_by_
            o.required_name_symbols = sidx.required_name_symbols
          end

          _wat  # hi. #todo
        end

        # --

        def define_methods__ mod

          st = @static_index_.method_definers.to_key_stream
          begin
            k = st.gets
            k or break
            @hash_.fetch( k ).deffers_.each do |p|
              p[ mod ]
            end
            redo
          end while nil
          NIL_
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

        def to_defined_attribute_stream__

          ea = @hash_.each_value
          Common_.stream do
            begin
              ea.next
            rescue ::StopIteration
            end
          end
        end

        def read_association_ k
          @hash_.fetch k
        end

        def read_association_by_
          @hash_.method :fetch
        end

        # --

        attr_reader(
          :_custom_index,
          :hash_,  # <- in anticipation of one client moving. but all this file for now
          :static_index_,
        )
      # -

      Writer_method_reader___ = -> cls do

        -> name_sym do

          m = Classic_writer_method_[ name_sym ]

          if cls.private_method_defined? m
            m
          end
        end
      end

      # ==

      class StackBasedAssociationSoftReader  # 1x

        def initialize
          @_array = []
        end

        def push_association_soft_reader_proc__ p
          @_array.push p ; nil
        end

        def flush_to_soft_reader_via_argument_scanner__ scn
          stack = remove_instance_variable :@_array
          if 1 < stack.length
            __when_tall_stack stack, scn
          else
            p = stack.fetch 0
            -> do
              p[ scn.head_as_is ]
            end
          end
        end

        def __when_tall_stack stack ,scn

          top_d = stack.length - 1

          -> do
            d = top_d
            k = scn.head_as_is
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

      class Build_Index_of_Definition___

        def initialize ma_cls, atr_cls

          @_p = -> kk, xx do

            n_meta_prototype = Here_::N_Meta_Attribute::Build.new ma_cls, atr_cls

            n_meta_prototype.attribute_services = self

            n_meta_prototype.build_N_plus_one_interpreter =
              Here_::N_Meta_Attribute::Common_build_N_plus_one_interpreter

            n_meta_prototype.finish_attribute = Finish_attribute___

            @_p = -> k, x do
              n_meta_prototype.__build_and_process_attribute k, x
            end

            @_p[ kk, xx ]
          end

          @_custom_index = nil
          @_static_index = StaticIndex___.new
        end

        def __build_and_index_attribute k, x
          @_p[ k, x ]
        end

        # -- exposures

        def add_to_the_custom_index_ k, meta_k

          _idx = ( @_custom_index ||= {} )
          _bx = _idx[ meta_k ] ||= Common_::Box.new
          _bx.add k, true  # so we can h[k] with a transparent h
        end

        def add_to_the_static_index_ k, meta_k
          @_static_index.add_ k, meta_k
        end

        SI_OP_H__ = {
          non_required_name_symbols: :_push_to_array,
          method_definers: :__add_to_box,
          required_name_symbols: :_push_to_array,
        }

        StaticIndex___ = ::Struct.new( * SI_OP_H__.keys ) do

          def add_ k, meta_k
            send SI_OP_H__.fetch( meta_k ), k, meta_k
          end

          def __add_to_box k, meta_k

            ( self[ meta_k ] ||= Common_::Box.new ).add k, nil
            NIL_
          end

          def _push_to_array k, meta_k

            ( self[ meta_k ] ||= [] ).push k
            NIL_
          end
        end

        # -- for client

        def __release_thing_ding_one
          remove_instance_variable :@_custom_index
        end

        def __release_thing_ding_two
          remove_instance_variable :@_static_index
        end
      end

      # --

      Finish_attribute___ = -> build do

        if ! build.current_attribute.parameter_arity
          build.add_to_static_index_ :required_name_symbols
        end

        NIL_
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
      # ==
    end
  end
end
# #tombstone: facility "I" assimilated into the main normalization facililty
# #tombstone-B: used to use plain old mutable session
# #tombstone: `edit_actor_class`
