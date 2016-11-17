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
            @_custom_emitter ||= CustomEmitter___.new
            @_custom_emitter.send m, p
            NIL
          end
        end

        # -- read

        def lookup_softly k

          key_as_slug = k.id2name.gsub UNDERSCORE_, DASH_

          st = _to_state_machine_stream
          begin
            sm = st.gets
            sm || break
            if key_as_slug == sm.entry_group_head
              break
            end
            redo
          end while above

          if sm
            _item sm
          end
        end

        def to_pair_stream

          _to_state_machine_stream do |sm|

            _k = sm.entry_group_head.gsub( DASH_, UNDERSCORE_ ).intern

            Common_::Pair.via_value_and_name _item( sm ), _k
          end
        end

        def _item sm
          LoadTicketIsh___.new sm, @module
        end

        def to_normal_symbol_stream & p

          st = _to_state_machine_stream do |sm|

            sm.entry_group_head.gsub( DASH_, UNDERSCORE_ ).intern
          end

          if block_given?
            st.map_by( & p )
          else
            st
          end
        end

        def to_slug_stream  # 1x for [tmx]. not an API #hook-out

          _to_state_machine_stream( & :entry_group_head )
        end

        def _to_state_machine_stream & p
          if block_given?
            @module.entry_tree.to_state_machine_stream.map_by( & p )
          else
            @module.entry_tree.to_state_machine_stream
          end
        end

        attr_reader(
          :emit_idea_by,
        )
      # -
#==FROM

      class CustomEmitter___

        # if the client wants to customize how the emissions "express"
        # (but not how they emit) this does all the lower-level writing.

        def initialize
          @channel_for_unknown_by = nil
          @express_unknown_by = nil
        end

        attr_writer(
          :channel_for_unknown_by,
          :express_unknown_by,
        )

        def finish
          freeze
        end

        def call idea
          dup.__init( idea ).execute
        end

        alias_method :[], :call

        def __init idea
          @idea = idea
          freeze
        end

        def execute

          if @idea.is_about_unknown_item && ( x = __customizations_about_unknown )  # etc
            __emit_customly x
          else
            @idea.emit_normally
          end
        end

        def __emit_customly x

          channel_by, express_idea_by = x
          idea = @idea

          channel = if channel_by
            channel_by[ idea ]
          else
            idea.get_channel
          end

          idea.listener.call( * channel ) do |y|

            expr = idea.to_expression_into_under y, self

            if express_idea_by
              express_idea_by[ expr ]
            else
              expr.express_normally
            end
          end

          UNABLE_
        end

        def __customizations_about_unknown
          @channel_for_unknown_by || @express_unknown_by and
            [ @channel_for_unknown_by, @express_unknown_by ]
        end

      end
#==TO
      # ==

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
