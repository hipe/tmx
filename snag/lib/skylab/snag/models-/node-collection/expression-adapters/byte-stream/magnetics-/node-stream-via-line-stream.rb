module Skylab::Snag

  class Models_::NodeCollection

    module ExpressionAdapters::ByteStream

      class Magnetics_::NodeStream_via_LineStream

        # parse the manifest file syntax: identifiers that start at column 1

        Attributes_actor_.call( self,
          :extended_content_adapter,
          :byte_upstream_ID,
          :simple_line_upstream,  # (if set, will shadow any `byte_upstream_ID`)
        )

        def initialize & p
          @on_event_selectively = p
          @simple_line_upstream = nil
        end

        def execute

          @is_hot = true
          @receive_first_line_of_stream = method :__init_memoized_assets

          _pxy = As_Rewinder_Releaser___.new self

          @p = method :__gets_first_node_ever

          Common_::Stream.by _pxy do
            @p[]
          end
        end

        attr_reader :simple_line_upstream

        def __gets_first_node_ever  # assume not after a rewind

          _ok = __resolve_line_upstream
          _ok && _gets_first_node_of_stream
        end

        def __resolve_line_upstream

          if @simple_line_upstream
            ACHIEVED_
          else
            __via_etc_resolve_SLS
          end
        end

        def __via_etc_resolve_SLS

          _ = @byte_upstream_ID.to_minimal_line_stream(
            & @on_event_selectively )

          _store :@simple_line_upstream, _
        end

        def __gets_first_node_after_EOF_or_rewind

          # hello
          @p = method :_gets_first_node_of_stream
          @p[]
        end

        def _gets_first_node_of_stream  # may be used after rewind *OR* EOF

          s = @simple_line_upstream.gets
          if s

            @receive_first_line_of_stream[ s ]
            __gets_first_node_via_first_line_of_stream

          else
            _EOF s
          end
        end

        def __init_memoized_assets s

          _BODY = []
          _STRING_SCANNER = Home_::Library_::StringScanner.new s

          _Models = Models_
          _Models_ = _Models::Node::ExpressionAdapters::ByteStream::Models_
          @Substring = _Models_::Substring

            # (we don't memoize instances of the above because it would
            #  require pooling and likely incur more cost than benefit)

          # ~ ID related

          @ID = _Models::NodeIdentifier.new_empty
          @ID_ = _Models::NodeIdentifier.new_empty

          @reinterpret_ID = _Models::NodeIdentifier::ExpressionAdapters::
            ByteStream.build_reinterpreter _STRING_SCANNER

          # ~ body related

          @body = _Models_::Body.via_range_and_substring_array nil, _BODY
          @body.receive_extended_content_adapter__ @extended_content_adapter

          @node = _Models::Node.via_body @body

          # ~ lowlevel

          @scn = _STRING_SCANNER
          @sstr_a = _BODY

          @receive_first_line_of_file = -> s_ do  # called IFF rewind

            _STRING_SCANNER.string = s_
            NIL_
          end

          NIL_
        end

        def __gets_first_node_via_first_line_of_stream  # may be used after rewind

          _ok = __gather_up_leading_non_identifier_lines
          _ok && __gets_first_node
        end

        def __gather_up_leading_non_identifier_lines

          begin

            if @reinterpret_ID[ @ID ]
              x = ACHIEVED_
              break
            end

            s = @simple_line_upstream.gets
            if s
              @sstr_a.push @Substring.new nil, nil, @scn.string
              @scn.string = s
              redo
            end
            break
          end while nil
          x
        end

        def __gets_first_node

          @start_new_node = -> do

            @business_line_range_begin = @sstr_a.length

            @start_new_node = -> do
              @business_line_range_begin = 0
              @sstr_a.clear

              @start_new_node = -> do
                @sstr_a.clear
                NIL_
              end

              NIL_
            end
            NIL_
          end

          @p = method :__gets_subsequent_node
          @p[]
        end

        def __gets_subsequent_node  # assume identifier is already parsed

          @business_line_range_end = nil
          @start_new_node[]
          __accept_first_node_line
          begin

            s = @simple_line_upstream.gets
            if ! s
              x = _EOF s
              break
            end

            @scn.string = s

            if @reinterpret_ID[ @ID_ ]
              x = _node
              break
            end

            d = @scn.skip WHITE__
            if d
              _accept_business_line_with_assumptions
              redo
            end

            x = __skip_all_lines_till_next_ID

            break
          end while nil
          x
        end

        def __skip_all_lines_till_next_ID

          # current line is non-business. skip *all* lines till next ID

          @business_line_range_end = @sstr_a.length
          begin
            @sstr_a.push @Substring.new( nil, nil, @scn.string )
            s = @simple_line_upstream.gets
            if ! s
              x = _EOF s
              break
            end
            @scn.string = s
            if @reinterpret_ID[ @ID_ ]
              x = _node
              break
            end
            redo
          end while nil
          x
        end

        def _EOF s

          # when we hit EOF it typically marks the end of whatever entity
          # we were in the middle of building. as such, the result of the
          # current `gets` call will be this entity and not the false-ish
          # that typically accompanies EOF. *however*, the *next* call to
          # `gets` *must* result in false-ish (unless the IO handle is re
          # wound, eek!)

          if @is_hot
            @is_hot = false
            @p = method :__gets_first_node_after_EOF_or_rewind
            _node
          else

            # assume that we had just done the above in the previous gets
            # NOTE this toggle is fragile and dangerous! it may be better
            # to change the ivar #here.

            @sstr_a.clear
            @is_hot = true
            s
          end
        end

        def _node

          __reinitialize_node
          id = @ID
          @ID = @ID_
          @ID_ = id
          @node
        end

        def __reinitialize_node

          @body.reinitialize(
            @business_line_range_begin ...
              ( @business_line_range_end || @sstr_a.length ) )

          @node.reinitialize @ID

          NIL_
        end

        def __accept_first_node_line

          @scn.skip WHITE__
          _accept_business_line_with_assumptions
          NIL_
        end

        def _accept_business_line_with_assumptions

          @sstr_a.push @Substring.new(
            @scn.pos,
            @scn.string.length - 1,  # dodgy, but meh for now
            @scn.string )
          NIL_
        end

        define_method :_store, DEFINITION_FOR_THE_METHOD_CALLED_STORE_

        # ==

        class As_Rewinder_Releaser___

          def initialize actor

            @rw = -> do

              # :#here might be a better place to reset the state of the thing

              actor.simple_line_upstream.rewind
            end

            @rr = -> do
              actor.simple_line_upstream.close
            end
          end

          def rewind
            @rw[]
          end

          def release_resource
            @rr[]
          end
        end

        # ==

        WHITE__ = /[ \t]+/

        # ==
        # ==
      end
    end
  end
end
# :+#tombstone: "the embodiment of [#059] scanners"
