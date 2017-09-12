module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_via_AutoloaderizedModule < Common_::SimpleModel  # :[#051.3].

      # the adaptation of #[#051] for autoloaderized modules.
      #
      # this was derived by heavily reafactoring two real-world but oblique
      # use-cases that can be found in our first #history entry below.
      #
      # now this is being used to drive the rewrite of [ts] quickie plugins..
      #
      # see also
      #   - [#051.2] "via module" for boxxy-like unobtrusiveness (in [ba])
      #   - [#051.7] for directories thru filesystem directly; no autoloading (in [sy])

      # -

        def initialize

          @_custom_emitter = nil
          yield self
          @sub_branch_const || fail
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
          :sub_branch_const,
          :module,
        )

        # -- read

        # ~ experiment for [pl]

        def natural_key_of my_custom_loadable_reference  # #here1
          my_custom_loadable_reference.asset_reference.entry_group_head
        end

        # ~

        def lookup_softly key_x  # #[#ze-051.1] "trueish item value"

          ::Symbol === key_x || self._OK__but_just_checking__

          _slug = Slug_via_symbol__[ key_x.intern ]  # #here2

          ar = _entry_tree.asset_reference_via_entry_group_head _slug

          if ar
            _trueish_item_value_via_asset_reference ar
          end
        end

        def dereference key_x  # #[#ze-051.1] "trueish item value"

          ::Symbol === key_x || self._FIX_THIS

          _slug = Slug_via_symbol__[ key_x.intern ]  # #here2

          _ar = _entry_tree.dereference_asset_reference_via_entry_group_head _slug

          _trueish_item_value_via_asset_reference _ar
        end

        def to_pair_stream

          _to_asset_reference_stream.map_by do |aref|

            _sym = Symbol_via_slug__[ aref.entry_group_head ]
            _x = _trueish_item_value_via_asset_reference aref

            Common_::QualifiedKnownKnown.via_value_and_symbol _x, _sym
          end
        end

        def to_loadable_reference_stream

          _to_asset_reference_stream.map_by do |aref|

            _trueish_item_value_via_asset_reference aref
          end
        end

        def to_slug_stream  # 1x for [tmx]. not an API #hook-out

          _to_asset_reference_stream.map_by do |aref|
            aref.entry_group_head
          end
        end

        def _to_asset_reference_stream
          _entry_tree.to_asset_reference_stream
        end

        def _entry_tree
          @module.entry_tree
        end

        def _trueish_item_value_via_asset_reference ref

          @loadable_reference_class.define do |o|
            o.asset_reference = ref
            o.module = @module
            o.sub_branch_const = @sub_branch_const
          end
        end

        attr_reader(
          :emit_idea_by,
          :loadable_reference_class,
          :module,
        )
      # -
      # ==

      class LoadableReferenceIsh___ < Common_::SimpleModel  # :#here1  # :TESTPOINT1:[pl]

        def asset_reference= ar
          @name_symbol = Symbol_via_slug__[ ar.entry_group_head ]
          @asset_reference = ar
        end

        attr_accessor(
          :module,
          :sub_branch_const,
        )

        def dereference_loadable_reference
          ref = @asset_reference
          if ref.value_is_known
            ref.value  # #hi. :[#008.2] #borrow-coverage from [ts]
          else
            Autoloader_.const_reduce_by do |o|
              o.const_path = [ ref.entry_group_head ]
              o.from_module = @module
              o.autoloaderize
            end
            # (if the below borks, then probably @module wasn't autoloaded)
            ref.value
          end
        end

        def intern  # :#here2: internally we allow ourselves to know shape
          name_symbol
        end

        attr_reader(
          :asset_reference,
          :name_symbol,
        )

        def HELLO_LOADABLE_REFERENCE  # #temporary
          NIL
        end
      end

      # ==

      Slug_via_symbol__ = -> k do
        k.id2name.gsub UNDERSCORE_, DASH_
      end

      Symbol_via_slug__ = -> s do
        s.gsub( DASH_, UNDERSCORE_ ).intern
      end

      # (above #open [#bs-044] - these are oft-repeated function written by hand)

      # ==
      # ==
    end
  end
end
# #history: abstracted from [tmx] (2 places)
