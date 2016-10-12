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

        def known_for_const_missing__ wrong_const

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

            head = Name.via_const_symbol( real_const ).as_slug
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

        def execute  # result in name value pair
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

          o = @_cm
          o.file_tree = @module.entry_tree
          o.state_machine = sm
          NIL
        end

        def __execute_that_real_const_missing  # result in name value pair

          o = @_cm

          o.const_defined = method :__you_better_correct_that_name_boi

          if o.become_loaded_via_filesystem_

            o.name_and_value_after_loaded_

          elsif __match_a_stowaway_record_somehow
            remove_instance_variable :@_name_and_value

          else

            # this case is covered, but is probably not ever used
            # in production #feature-island (unconfirmed)

            o.become_loaded_via_autovivifying_a_module_
            o.name_and_value_after_loaded_
          end
        end

        def __match_a_stowaway_record_somehow

          # for an item under a boxxy that does not have one of the main two
          # storage means (eponymous or corefile), rather than autovivifying
          # outright, see first if you can correct the name thru stowaways.
          # this is more "payback" work because we don't take stowaways into
          # account eariler on the pipeline (as maybe we should) where we
          # hack `constants` to infer things.. (but even if this could be
          # improved, it's all just for one field edge case.)

          o = @_cm
          if o.has_stowaway_hash_
            if o.has_stowaway_record_for_const_as_is_
              @_name_and_value = o.name_and_value_via_stowaway_ ; ACHIEVED_
            else
              __try_this_crazy_money
            end
          end
        end

        def __try_this_crazy_money

          # when there is a stowaway hash and there is no direct match
          # for a name, try to fuzzy match on a stowaway entry egads

          o = @_cm
          _h = o.module.stowaway_hash_

          fl = Here_::FuzzyLookup_.new

          fl.constants = _h.keys

          fl.on_exactly_one = -> sym do
            @_cm.const_symbol = sym
            ACHIEVED_
          end

          fl.on_zero = -> do
            UNABLE_  # fall thru
          end

          _yes = fl.execute_for @module, @_cm.name_

          if _yes
            @_name_and_value = o.name_and_value_via_stowaway_
            ACHIEVED_
          else
            UNABLE_
          end
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

          normally = method :__index_probable_asset

          p = -> sm do
            if CORE_ENTRY_STEM == sm.entry_group_head
              # boxxy modules usually don't have a corefile but they might (covered)
              p = normally
              NOTHING_
            else
              normally[ sm ]
              NIL
            end
          end

          st = mod.entry_tree.to_state_machine_stream_proc_
          begin
            sm = st.call
            sm || break
            p[ sm ]
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
    end  # :#bo
  end
end
