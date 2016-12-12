module Skylab::Zerk

  module ArgumentScanner

    class OperatorBranch_via_AutoloaderizedModule

      # the adaptation of #[#051] for autoloaderized modules.
      #
      # this was derived by heavily reafactoring two real-world but oblique
      # use-cases that can be found in our first #history entry below.

      class << self
        alias_method :define, :new
        undef_method :new
      end  # >>

      # -

        def initialize mod

          @item_class = LoadTicketIsh___
          @module = mod

          @_custom_emitter = nil

          yield self

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

        def item_class cls
          @item_class = cls ; nil
        end

        # -- read

        def lookup_softly k

          sm = @module.entry_tree.value_state_machine_via_head Slug_via_symbol__[k]
          if sm
            _item_via_state_machine sm
          end
        end

        def dereference k

          _slug = Slug_via_symbol__[ k ]

          @module.entry_tree.dereference_value_state_machine_via_head _slug
        end

        def to_pair_stream

          @module.entry_tree.to_state_machine_stream.map_by do |sm|

            Common_::Pair.via_value_and_name(
              _item_via_state_machine( sm ),
              Symbol_via_slug__[ sm.entry_group_head ] )
          end
        end

        def to_normal_symbol_stream

          @module.entry_tree.to_state_machine_stream.map_by do |sm|
            Symbol_via_slug__[ sm.entry_group_head ]
          end
        end

        def to_slug_stream  # 1x for [tmx]. not an API #hook-out

          @module.entry_tree.to_state_machine_stream.map_by do |sm|
            sm.entry_group_head
          end
        end

        def _item_via_state_machine sm
          @item_class.new sm, @module
        end

        attr_reader(
          :emit_idea_by,
        )
      # -
      # ==

      Slug_via_symbol__ = -> k do
        k.id2name.gsub UNDERSCORE_, DASH_
      end

      Symbol_via_slug__ = -> s do
        s.gsub( DASH_, UNDERSCORE_ ).intern
      end

      class LoadTicketIsh___

        def initialize sm, mod
          @module = mod
          @state_machine = sm
        end

        attr_reader(
          :module,
          :state_machine,
        )
      end

      # ==
    end
  end
end
# #history: abstracted from [tmx] (2 places)
