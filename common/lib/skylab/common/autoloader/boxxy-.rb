module Skylab::Common

  module Autoloader

    module Boxxy_  # [#030]

      module Reflection  # a stowaway sort of

        Each_const_value_method = -> & p do

          constants.each do |sym|
            p[ const_get sym, false ]
          end
        end
      end

      # ==

      class OperatorBranch_via_Module  # 1x

        class << self
          alias_method :call, :new
          alias_method :[], :call
          undef_method :new
        end  # >>

        def initialize mod

          @module = mod

          _p = method :__value_of
          @index = Index_via_Module___.new( _p, @module ).execute

          _these = @index.item_offset_via_const.keys
          @_pool = ::Hash[ _these.map { |k| [ k, true ] } ]
          # as discussed below and [#here], whenever we encounter a real..


          @_seen = {}  # as discussed below and [#here], we exploit the fact
          # that although you can always set a new const, you can never
          # unset a const. as such, if we've seen any real const once, we
          # assume it will always be present at subsequent reflections.

          @_augment = :__augment_while_active
        end

        # ~( exposition of a selection of [#ze-051.2] operator branch methods
        #
        #    - experimental, #open [#041] only covered by [cu]
        #
        #    - index "items" are *the* items, *not* const values.
        #      if it is useful to develop this, see [#cu-010]

        def lookup_softly name_sym
          d_a = @index.item_offsets_via_name_symbol[ name_sym ]
          if d_a
            _via_item_offsets d_a
          end
        end

        def has_reference name_sym

          # (this had an exlucsive client in [cu], but #tombstone-3.3 no longer)
          self._NOT_USED__but_worked_once__

          # (to keep things simple, this will only detect those that have
          # already been indexed (so stowaways and filesystem nodes) which
          # is fine #theme-here)

          @index.item_offsets_via_name_symbol[ name_sym ] && true
        end

        def dereference name_sym

          # a bit shaky but it's ok -
          # it's forseeable that the client would find it useful to have
          # the name (function) as part of the result structure (if not
          # as the result itself), (and keep in mind this would be free
          # for us because we produce a name function when indexing);
          # however not to result in the loaded const value ("asset") would
          # A) seem to violate the semantics of the method and B) put onus
          # on the client to know how to *actually* dereference it.
          # our solution is to result in our internal indexing item
          # structure, but to enusre that the asset is loaded here..

          _via_item_offsets @index.item_offsets_via_name_symbol[ name_sym ]
        end

        def _via_item_offsets d_a
          1 == d_a.length || self._COVER_ME__bah__
          @index.items.fetch d_a.fetch 0
        end

        def to_loadable_reference_stream

          # (if there is a need to, map `constants` instead (but still result
          # in a stream of items). for now we'll keep it simple and assume
          # that the items you want to map are either filesystem- or
          # stowaway- based #theme-here)

          # (we assume that (in our index) there is one item per const)

          Stream.via_nonsparse_array @index.items
        end

        # ~)

        def __value_of ref, item
          # assume that ref either does not exist or has unknown value
          if ref
            name_and_value_for_const_missing_ item.name.as_const
            ref.value_is_known || self._SANITY
            ref.value
          else
            # (probably a stowaway that is not yet loaded)
            _nv = _same_by do |o|
              o.wrong_name = item.name
            end
            _nv.const_value
          end
        end

        def name_and_value_for_const_missing_ wrong_const
          _same_by do |o|
            o.wrong_const = wrong_const
          end
        end

        def _same_by

          MyConstMissing___.call_by do |o|
            yield o
            o.operator_branch = self
            o.module = @module
          end
        end

        def boxxy_enhanced_constants_

          a = @module.boxxy_original_constants_method_.call
          send @_augment, a
          a
        end

        def __augment_while_active a

          # exactly [#here.D.4] (see). assume 'a' is mutable and represents
          # the real consts defined currently.

          index = @index ; pool = @_pool ; seen = @_seen

          a.each do |c|

            # for any and every const under the module, it is never necessary
            # to do all the below work more than once. (doing it again will
            # never add anything and might break things)

            seen[ c ] && next
            seen[ c ] = true

            # now this is a real life const that we've never seen

            # if the const as-is is identical to one of ours, don't
            # redundantly inject this const ourselves (now or ever).

            _yes = pool.delete c
            _yes && next

            # now we have a real life const that doesn't match any *const*
            # in our index (i.e stowaways and filesystem nodes). but this
            # real const might match something in our index via distilled
            # key. (more on this below)
            #
            # as is our habit (justified [#here5]), we don't ever want to
            # build the same name object twice if we can avoid it so:

            nm = Name.via_const_symbol c

            d_a = index.item_offsets_via_distilled_key[ nm.as_approximation ]

            if d_a
              _did = __maybe_correct_const_name d_a, nm
              _did && next
            end

            # it's certainly possible for there to exist a real const that
            # has neither a corresponding stowaway entry nor a matching
            # filesystem node. any random const should be able to just "be
            # there" when we get here, having gotten there by plain old
            # programming (e.g having been written in code in the ordinary
            # way) and we don't want to fall over on these cases.
            #
            # one place this happens in nature is when we don't have a
            # corresponding directory (and maybe stowaways, maybe not) and
            # we are just using boxxy for its reflection capabilities.
            #
            # because we made the name, we'll cache it..
            # #cov1.3

            index.add_item_by do |o|
              o.have_correct_const_symbol
              o.name = nm
            end
          end

          if pool.length.zero?
            # once we have nothing left in our pool to add, skip all this next time
            remove_instance_variable :@_pool
            remove_instance_variable :@_seen
            @_augment = :__augment_with_nothing
          else
            a.concat pool.keys  # wee
          end
          NIL
        end

        def __maybe_correct_const_name d_a, nm

          did = nil
          d_a.each do |d|
            item = @index.items.fetch d

            if item.is_stowaway
              # by design stowaways are registered using correct const
              # names, so if the real const matches the stowaway by
              # distilled name but not by const, the stowaway name is
              # still injected! whew!
              self._COVER_ME__read_this_reasoning__we_have_a_plan
              next
            end

            if ! @index.FS_asset_reference_via_item_offset.key? d
              # if this item was not a stowaway then it's either a
              # filesystem-derived one, or it's one we added here (below)
              # (right?). if it's one we added here then presumably there
              # are two real consts with similar names, ignore.
              self._COVER_ME__read_this_reasoning__we_have_a_plan
              next
            end

            # now, the item appears to be a filesystem-derived item
            # that has matched by distilled name the real const. in such
            # cases we CORRECT THE CONST NAME of the item in our index..
            # #cov1.2

            did && fail  # multiple filesystem slugs that match? how?
            did = true

            _correct_name nm, d
          end
          did
        end

        def _correct_name nm, d

          item = @index.items.fetch d

          h = @index.item_offset_via_const

          incorrect_const_sym = item.name.as_const
          c = nm.as_const

          _yes = @_pool.delete incorrect_const_sym
          _yes || fail
            # (the pool is what ultimately determines what we inject -
            #  get the incorrect name out of the pool as well as the index)

          @_seen[ c ] = true  # although you haven't technically "seen"
          # it (in the work loop), since you're updating the index,
          # you effectively have seen

          _d_ = h.delete incorrect_const_sym
          d == _d_ || fail

          h[ c ] && fail
          h[ c ] = d

          item.has_correct_const_symbol && fail
          item.have_correct_const_symbol
          item.name = nm  # overwrite entire bad name - meh
          NIL
        end

        def __augment_with_nothing a
          NIL  # hi. #cov1.3
        end

        attr_reader(
          :index,  # here only
          :module,  # [cu]
        )
      end

      # ==

      class MyConstMissing___ < MagneticBySimpleModel

        def wrong_name= nm
          c = nm.as_const
          @wrong_const_symbol = c
          @wrong_const = c
          @wrong_name = nm
        end

        def wrong_const= x
          if x.respond_to? :ascii_only?
            @wrong_name = Name.via_const_string x
            @wrong_const_symbol = x.intern
          else
            @wrong_name = Name.via_const_symbol x
            @wrong_const_symbol = x
          end
          @wrong_const = x
        end

        def operator_branch= ob
          @_correct_name = ob.method :_correct_name
          @index = ob.index
        end

        attr_writer(
          :module,
        )

        def execute

          __init

          if __find_item_by_exact_name
            __when_found_item_by_exact_name

          elsif __find_item_by_distilled_name
            __when_found_item_by_distilled_name

          else
            __name_error
          end
        end

        # -- E

        def __when_found_item_by_distilled_name

          # experimentally, we're gonna assume some things

          found_item = nil ; found_item_offset = nil
          _d_a = remove_instance_variable :@__offsets
          _d_a.each do |d|
            item = @index.items.fetch d
            @index.FS_asset_reference_via_item_offset.key? d or next
            found_item = item ; found_item_offset = d
            break
          end
          if found_item
            @_item_offset = found_item_offset
            @_item = found_item
            if _has_file_to_load_so_load
              _when_file_loaded
            else
              self.__UMMM
            end
          else
            self._COVER_ME__fall_through__
          end
        end

        def __find_item_by_distilled_name

          # as is our habit (see)

          _distilled_key = @wrong_name.as_approximation

          _d_a = @index.item_offsets_via_distilled_key[ _distilled_key ]
          _store :@__offsets, _d_a
        end

        # -- D

        def __when_found_item_by_exact_name

          @_item = @index.items.fetch @_item_offset
          if @_item.is_stowaway
            # #cov1.8
            @_cm.name_and_value_via_stowaway_
          elsif _has_file_to_load_so_load
            _when_file_loaded
          else
            __autovivify_a_module  # :#cov1.6
          end
        end

        def __find_item_by_exact_name

          _d = @index.item_offset_via_const[ @wrong_const_symbol ]
          _store :@_item_offset, _d
        end

        # -- C

        def _when_file_loaded
          @_cm.name_and_value_after_loaded_
          # CorrectConstForBoxxy___[ @_cm.the_asset_value_, @_item.name ]
        end

        def _has_file_to_load_so_load

          __init_for_loady_time

          _yes = @_cm.become_loaded_via_filesystem_
            # (this triggers all of the below, remainder of this section)
          _yes  # hi.
        end

        def __you_better_correct_that_name_boi(*)

          # this is being called because the upstairs performer has loaded
          # the file and is now asking whether or not the const is defined.
          #
          # we have hooked-in to (customized) this particular function of
          # the performer so that we can correct the name if our inferred
          # name doesn't match whatever is ostensibly the correct name..
          #
          # (this might be very similar to what [#029] const reduce does.)

          if @module.const_defined? @wrong_const_symbol, false
            ACHIEVED_  # #cov1.9
          else
            __after_name_correction_is_const_defined
          end
        end

        def __after_name_correction_is_const_defined

          # the file has been loaded but the "wrong const" was not among
          # any zero or more consts that were loaded by the file..

          if __find_correct_const_symbol
            __via_correct_const_symbol
          else
            THE_CONST_IS_NOT_DEFINED__  # hi. #cov1.5 -
            # pass this failure to upstairs and the right thing happens
          end
        end

        def __via_correct_const_symbol

          c = remove_instance_variable :@__correct_const_symbol

          _nm = Name.via_const_symbol c

          @_correct_name[ _nm, @_item_offset ]  # correct the name in our own index

          @_cm.const_symbol = c  # this is the main crucial thing

          THE_CONST_IS_DEFINED__
        end

        def __find_correct_const_symbol

          _all_real = @module.boxxy_original_constants_method_.call

          # consts that are loaded now that are not in our index:

          newly_loaded_a = _all_real - @index.item_offset_via_const.keys

          if newly_loaded_a.length.zero?
            self._COVER_ME__it_might_be_fine_to_fall_through__
          end

          fl = Here_::FuzzyLookup_.new

          fl.constants = newly_loaded_a

          fl.on_exactly_one = -> correct_const_sym do
            correct_const_sym  # hi. (to #here1)
          end

          fl.on_zero = -> do
            UNABLE_  # #cov1.5 fall thru
          end

          _correct_const_sym = fl.execute_for @module, @wrong_name  # :#here1

          _store :@__correct_const_symbol, _correct_const_sym
        end

        def __init_for_loady_time

          ref = @index.FS_asset_reference_via_item_offset.fetch @_item.item_offset
          ref.value_is_known && self._COVER_ME__read_me__  # incorrect name used. but why?

          o = @_cm
          o.file_tree = @module.entry_tree
          o.asset_reference = ref
          o.const_defined = method :__you_better_correct_that_name_boi
          NIL
        end

        # -- B

        def __autovivify_a_module
          @_cm.become_loaded_via_autovivifying_a_module_
          @_cm.name_and_value_after_loaded_
        end

        # -- A

        def __name_error
          @_cm.raise_name_error_no_filesystem_node_  # #cov1.4
        end

        def __init
          @_cm = Here_::ConstMissing_.new @wrong_const, @module
          NIL
        end

        def _store ivar, x  # DEFINITION_FOR_THE_METHOD_CALLED_STORE_
          if x
            instance_variable_set ivar, x ; true
          end
        end

        attr_writer :_wrong_name  # shh..
      end

      # ==

      class Index_via_Module___

        # (this is the evolution of [#here.5] "why we cache names and ..)

        def initialize p, mod

          @item_offset_via_const = {}
          @item_offsets_via_distilled_key = {}
          @item_offsets_via_name_symbol = {}

          @FS_asset_reference_via_item_offset = {}

          @__value_of = p
          @items = []
          @module = mod
        end

        def execute
          __index_any_stowaways
          __index_any_filesystem_nodes
          remove_instance_variable :@module
          self
        end

        # -- C

        def __index_any_filesystem_nodes
          et = @module.entry_tree
          if et
            __index_filesystem_nodes et
          end
        end

        def __index_filesystem_nodes et

          st = et.to_asset_reference_stream_proc_
          begin
            ref = st.call
            ref || break
            slug = ref.entry_group_head

            if CORE_ENTRY_STEM == slug  # code note [#here.G.2]
              redo
            end

            c = @module.boxxy_const_guess_via_slug slug

            # this part is tricky, and near #cov1.7: all we're trying to do
            # is gather up a list of consts to inject and/or retrieve to
            # augment the real-life constspace. if we have one *OR MORE*
            # stowaways that match this filesystem node, practice dictates
            # that we match these up. so given filesytem node "foo-bar",
            # normally this suggests `FooBar` (let's say), but if you have
            # stowaways `FOO_Bar` and `Foo_Bar`, A) don't go so far as to
            # assume `FooBar` exists and B) associate the filesystem node
            # with the stowaways (somehow)..

            # in practice we belive this case occurs, but it's rare. as such
            # we create a name object first, and in the case of a match we
            # throw the object away..

            if c
              nm = Name.via_const_symbol c.intern
                # (we didn't specify that it has to be a symbol)
            else
              nm = Name.via_slug slug
            end

            _distilled_key = nm.as_approximation

            d_a = @item_offsets_via_distilled_key[ _distilled_key ]

            if d_a
              d_a.each do |d|  # #cov1.7
                @FS_asset_reference_via_item_offset[ d ] = ref
                # (it's OK if multiple stowaways exist associate with one FS node)
                # (in theory such items will nonetheless use the stowaway strategy
                #  alone to resolve the const value, at #here2)
              end
            else
              _d = add_item_by do |o|
                o.name = nm
              end
              @FS_asset_reference_via_item_offset[ _d ] = ref
            end
            redo
          end while above
        end

        # -- B

        def __index_any_stowaways
          h = @module.stowaway_hash_
          if h
            __index_stowaways h
          end
        end

        def __index_stowaways h

          h.keys.each do |c|

            add_item_by do |o|
              o.name = Name.via_const_symbol c
              o.have_correct_const_symbol
              o.be_stowaway
            end
          end
        end

        # -- A

        def add_item_by

          d = @items.length

          item = Item___.define do |o|
            yield o
            o.value_by = -> do
              __my_value_of item
            end
            o.item_offset = d
          end

          nm = item.name

          _had = @item_offset_via_const.fetch nm.as_const do |c|
            @item_offset_via_const[ c ] = d ; nil
          end

          _had && self._SANITY__read_me__  # because each stowaway entry
          # is stored in a plain old hash keyed to its const name, these
          # are "guaranteed" never to have name collisions with each other.
          # since filesystem nodes are matched to existing stowaways using
          # distilled keys we infer that we will never collide const names
          # (but we don't know how to prove this.)

          @items.push item

          _distilled_key = nm.as_approximation
          ( @item_offsets_via_distilled_key[ _distilled_key ] ||= [] ).push d

          _k = nm.as_lowercase_with_underscores_symbol
          ( @item_offsets_via_name_symbol[ _k ] ||= [] ).push d

          d
        end

        def __my_value_of item
          ref = @FS_asset_reference_via_item_offset[ item.item_offset ]
          if ref
            if ref.value_is_known
              ref.value
            else
              @__value_of[ ref, item ]
            end
          else
            @__value_of[ ref, item ]
          end
        end

        # ==

        attr_reader(
          :FS_asset_reference_via_item_offset,
          :item_offset_via_const,
          :item_offsets_via_distilled_key,
          :item_offsets_via_name_symbol,
          :items,
        )
      end

      # ==

      class Item___ < SimpleModel

        def initialize
          yield self
          # not freeze because mutates later
        end

        def value_by= p
          @value = :__value_initially
          @__p = p
        end

        def be_stowaway
          @is_stowaway = true
        end

        def have_correct_const_symbol
          @has_correct_const_symbol = true
        end

        attr_accessor(
          :name,
          :item_offset,  # write once!
        )

        def value
          send @value
        end

        def __value_initially
          @value = :__value
          @__value = remove_instance_variable( :@__p )[]
          send @value
        end

        def __value
          @__value
        end

        attr_reader(
          :has_correct_const_symbol,
          :is_stowaway,
        )
      end

      # ==

      THE_CONST_IS_DEFINED__ = true
      THE_CONST_IS_NOT_DEFINED__ = false

      # ==
      # ==
    end  # :#bo
  end
end
# :#tombstone-3.3 (as referenced) (can be temporary)
# #history-3.2: spike of initial code of boxxy reflection API that includes stowaways
# #tombstone-3.1: full overhaul during "operator branch" era
#   (tombstones 1 & 2 are in our main spec file - they occurred before this file existed)
