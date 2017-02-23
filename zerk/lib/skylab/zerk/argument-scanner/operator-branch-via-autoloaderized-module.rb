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
          @load_ticket_class ||= LoadTicketIsh___

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
          :load_ticket_class,
          :module,
        )

        # -- read

        # ~ experiment for [pl]

        def natural_key_of my_custom_load_ticket  # #here
          my_custom_load_ticket.asset_ticket.entry_group_head
        end

        def dereference_user_value my_custom_load_ticket  # #here

          at = my_custom_load_ticket.asset_ticket

          _cls = if at.value_is_known
            at.value_x  # :[#008.2] #borrow-coverage from [ts]
          else
            Autoloader_.const_reduce_by do |o|
              o.from_module = @module
              o.const_path = [ at.entry_group_head ]
              o.autoloaderize
            end
          end
          _cls  # #todo
        end

        # ~

        def lookup_softly k  # #[#ze-051.1] "trueish item value"

          at = @module.entry_tree.
            asset_ticket_via_entry_group_head Slug_via_symbol__[k]
          if at
            _trueish_item_value_via_asset_ticket at
          end
        end

        def dereference k  # #[#ze-051.1] "trueish item value"

          _at = @module.entry_tree.
            dereference_asset_ticket_via_entry_group_head Slug_via_symbol__[k]
          _trueish_item_value_via_asset_ticket _at
        end

        def to_pair_stream

          @module.entry_tree.to_asset_ticket_stream.map_by do |at|

            Common_::Pair.via_value_and_name(
              _trueish_item_value_via_asset_ticket( at ),
              Symbol_via_slug__[ at.entry_group_head ] )
          end
        end

        def to_load_ticket_stream

          @module.entry_tree.to_asset_ticket_stream.map_by do |sm|
            Symbol_via_slug__[ sm.entry_group_head ]
          end
        end

        def to_slug_stream  # 1x for [tmx]. not an API #hook-out

          @module.entry_tree.to_asset_ticket_stream.map_by do |sm|
            sm.entry_group_head
          end
        end

        def _trueish_item_value_via_asset_ticket at

          @load_ticket_class.new at, @module
        end

        attr_reader(
          :emit_idea_by,
          :load_ticket_class,
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

      class LoadTicketIsh___  # :#here

        def initialize at, mod
          @asset_ticket = at
          @module = mod
        end

        attr_reader(
          :asset_ticket,
          :module,
        )

        def HELLO_LOAD_TICKET  # #temporary
          NIL
        end
      end

      # ==
    end
  end
end
# #history: abstracted from [tmx] (2 places)
