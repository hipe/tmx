module Skylab::Common

  module Autoloader

    module Boxxy_  # [#030]

      class Controller

        def initialize mod

          if mod.entry_tree
            @_has_pool = true
            @_pool = Pool___.new mod
          else
            @_has_pool = false
          end

          @__module = mod

          o = mod.boxxy_original_methods__
          @_orig_constants_method = o.constants
        end

        def constants__
          a = @_orig_constants_method.call
          if @_has_pool
            @_pool.__supplant a
            if @_pool.is_empty
              @_has_pool = false
            end
          end
          a
        end

        def name_value_pair_for_const_missing__ wrong_const

          if @_has_pool
            __name_value_pair_for_const_missing_normally wrong_const
          else
            _nf = Name.via_const_symbol wrong_const
            raise Here_::NameError, Here_::Say_::No_filesystem_node[ _nf, @__module ]
          end
        end

        def __name_value_pair_for_const_missing_normally wrong_const

          MyConstMissing___.new( wrong_const, @_pool, @_orig_constants_method ).execute
        end
      end

      # ==

      class Supplant___

        def initialize a, seen, box
          @a = a ; @box = box ; @seen = seen
        end

        def execute

          __of_the_consts_you_have_never_seen_before_remove_them_from_the_pool
          __then_do_something_else
          NIL
        end

        def __of_the_consts_you_have_never_seen_before_remove_them_from_the_pool

          seen = @seen
          pa_h = @box.h_

          remove_these = nil

          @a.each do |real_const|
            seen[ real_const ] && next
            seen[ real_const ] = true

            head = Head_via_const__[ real_const ]
            pa_h.key? head or next
            ( remove_these ||= [] ).push head
          end

          if remove_these
            @box.algorithms.delete_multiple remove_these
          end
          NIL
        end

        def __then_do_something_else
          a = @a
          @box.each_value do |pa|
            a.push pa.name.as_const  # or maybe as_camelcase_const_string ..
          end
          NIL
        end
      end

      # ==

      class MyConstMissing___

        # make the magic happen - pay everything back

        def initialize sym, pool, p
          @orig_constants_method = p
          @module = pool.module
          @pool = pool
          @wrong_const = sym
        end

        def execute
          __for_now_we_will_assume_we_have_a_probable_asset_for_this_const
          __for_now_we_will_assume_that_the_value_is_not_known_for_this_asset
          __execute_that_real_const_missing
        end

        def __for_now_we_will_assume_we_have_a_probable_asset_for_this_const

          @_cm = Here_::ConstMissing_.new @wrong_const, @module
          _slug = @_cm.name_.as_slug
          pa = @pool.__probable_asset_via_head _slug
          if ! pa
            self._HAVE_FUN
          end
          @_probable_asset = pa ; nil
        end

        def __for_now_we_will_assume_that_the_value_is_not_known_for_this_asset

          sm = @_probable_asset.state_machine

          if sm.value_is_known
            # then an incorrect name was used, but why?
            self._HAVE_FUN_readme
          end

          @_cm.file_tree = @module.entry_tree

          @_cm.state_machine = sm
          NIL
        end

        def __execute_that_real_const_missing

          @_cm.const_defined = method :__you_better_correct_that_name_boi

          _kn = @_cm.name_value_pair_after_maybe_load_then_cache_

          _kn  # #todo
        end

        def __you_better_correct_that_name_boi(*)

          fl = Here_::FuzzyLookup_.new

          fl.constants = @orig_constants_method.call

          fl.on_exactly_one = -> sym do
            @_cm.const_symbol = sym
            ACHIEVED_
          end

          fl.on_zero = -> do
            UNABLE_  # fall thru
          end

          _yes_or_no = fl.execute_for @module, @_cm.name_

          _yes_or_no  # #todo
        end
      end

      # ==

      class Pool___

        def initialize mod

          __init_for_indexing

          st = mod.entry_tree.to_state_machine_stream_proc_
          begin
            sm = st.call
            sm || break
            __index_probable_asset sm
            redo
          end while above

          __finish_indexing

          @_real_const_seen = {}
          @module = mod
          NIL
        end

        def __init_for_indexing
          @_box = Home_::Box.new
          NIL
        end

        def __index_probable_asset sm
          pa = ProbableAsset___.new sm
          @_box.add pa.head, pa
          NIL
        end

        def __finish_indexing
          @is_empty = @_box.length.zero?
        end

        def __supplant a
          Supplant___.new( a, @_real_const_seen, @_box ).execute
          if @_box.length.zero?
            @is_empty = true
          end
          a
        end

        def __probable_asset_via_head head
          @_box[ head ]
        end

        attr_reader(
          :is_empty,
          :module,
        )
      end

      # ==

      class ProbableAsset___

        def initialize sm

          head = sm.entry_group.head
          @name = Name.via_slug head
          @head = head
          @state_machine = sm
        end

        attr_reader(
          :head,
          :name,
          :state_machine,
        )
      end

      # ==

      Head_via_const__ = -> sym do
        Name.via_const_symbol( sym ).as_slug
      end

      # ==
    end  # :#bo
  end
end
