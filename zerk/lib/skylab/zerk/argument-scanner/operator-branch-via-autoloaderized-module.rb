module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_via_AutoloaderizedModule < Common_::SimpleModel  # :[#051.C].

      # the adaptation of #[#051] for autoloaderized modules.
      #
      # this was derived by heavily reafactoring two real-world but oblique
      # use-cases that can be found in our first #history entry below.
      #
      # now this is being used to drive the rewrite of [ts] quickie plugins..
      #
      # see also
      #   - [#051.B] "via module" for boxxy-like unobtrusiveness
      #   - [#051.G] for directories thru filesystem directly; no autoloading

      # -

        def initialize

          @_custom_emitter = nil
          yield self
          @loadable_reference_class ||= LoadableReferenceIsh___

          ce = remove_instance_variable :@_custom_emitter
          if ce
            ce = ce.finish
            @emit_idea_by = -> idea do
              ce[ idea ]
            end
          end

          freeze
        end

        def channel_for_unknown_by & p
          _maybe_customize p, :channel_for_unknown_by=
        end

        def express_unknown_by & p
          _maybe_customize p, :express_unknown_by=
        end

        def _maybe_customize p, m
          if p
            @_custom_emitter ||= Here_::CustomEmitter.new
            @_custom_emitter.send m, p
            NIL
          end
        end

        attr_writer(
          :loadable_reference_class,
          :module,
        )

        # -- read

        # ~ experiment for [pl]

        def natural_key_of my_custom_loadable_reference  # #here
          my_custom_loadable_reference.asset_reference.entry_group_head
        end

        def dereference_user_value my_custom_loadable_reference  # #here

          ref = my_custom_loadable_reference.asset_reference

          _cls = if ref.value_is_known
            ref.value  # :[#008.2] #borrow-coverage from [ts]
          else
            Autoloader_.const_reduce_by do |o|
              o.from_module = @module
              o.const_path = [ ref.entry_group_head ]
              o.autoloaderize
            end
          end
          _cls  # #todo
        end

        # ~

        def lookup_softly k  # #[#ze-051.1] "trueish item value"

          ref = @module.entry_tree.
            asset_reference_via_entry_group_head Slug_via_symbol__[k]
          if ref
            _trueish_item_value_via_asset_reference ref
          end
        end

        def dereference k  # #[#ze-051.1] "trueish item value"

          _at = @module.entry_tree.
            dereference_asset_reference_via_entry_group_head Slug_via_symbol__[k]
          _trueish_item_value_via_asset_reference _at
        end

        def to_pair_stream

          @module.entry_tree.to_asset_reference_stream.map_by do |ref|

            _sym = Symbol_via_slug__[ ref.entry_group_head ]
            _x = _trueish_item_value_via_asset_reference ref

            Common_::QualifiedKnownKnown.via_value_and_symbol _x, _sym
          end
        end

        def to_loadable_reference_stream

          @module.entry_tree.to_asset_reference_stream.map_by do |sm|
            Symbol_via_slug__[ sm.entry_group_head ]
          end
        end

        def to_slug_stream  # 1x for [tmx]. not an API #hook-out

          @module.entry_tree.to_asset_reference_stream.map_by do |sm|
            sm.entry_group_head
          end
        end

        def _trueish_item_value_via_asset_reference ref

          @loadable_reference_class.new ref, @module
        end

        attr_reader(
          :emit_idea_by,
          :loadable_reference_class,
          :module,
        )
      # -
      # ==

      Slug_via_symbol__ = -> k do
        k.id2name.gsub UNDERSCORE_, DASH_
      end

      Symbol_via_slug__ = -> s do
        s.gsub( DASH_, UNDERSCORE_ ).intern
      end

      class LoadableReferenceIsh___  # :#here

        def initialize ref, mod
          @asset_reference = ref
          @module = mod
        end

        attr_reader(
          :asset_reference,
          :module,
        )

        def HELLO_LOADABLE_REFERENCE  # #temporary
          NIL
        end
      end

      # ==
    end
  end
end
# #history: abstracted from [tmx] (2 places)
