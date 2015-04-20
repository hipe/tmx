module Skylab::Snag

  module Models_::Node_Collection

    module Expression_Adapters::Byte_Stream

      class Actors_::Produce_node_upstream

        # parse the manifest file syntax: identifiers that start at column 1

        Callback_::Actor.call self, :properties,

          :extended_content_adapter,
          :byte_upstream_ID

        def execute

          @p = -> do
            __produce_the_first_node
          end

          o = Callback_::Stream
          o.new(
            o::Release_Resource_Proxy.new do
              @line_upstream.close
            end
          ) do
            @p[]
          end
        end

        def __produce_the_first_node

          _ok = __resolve_line_upstream
          _ok && __via_line_upstream_produce_first_node
        end

        def __resolve_line_upstream

          us = @byte_upstream_ID.to_simple_line_stream(
            & @on_event_selectively )

          us and begin
            @line_upstream = us
            ACHIEVED_
          end
        end

        def __via_line_upstream_produce_first_node

          s = @line_upstream.gets
          if s
            __produce_first_node_via_first_line s
          else
            @p = EMPTY_P_
            s
          end
        end

        def __produce_first_node_via_first_line s

          a = []
          models = Snag_::Models_
          o = models::Node::Expression_Adapters::Byte_Stream::Models_
          scn = Snag_::Library_::StringScanner.new s

          @body = o::Body.via_range_and_substring_array nil, a

          @body.receive_extended_content_adapter__ @extended_content_adapter

          @ID = models::Node_Identifier.new
          @ID_ = models::Node_Identifier.new

          @node = models::Node.new_via_body @body

          @reinterpret_ID = models::Node_Identifier::Expression_Adapters::
            Byte_Stream.build_reinterpreter scn

          @scn = scn
          @sstr_a = a
          @Substring = o::Substring

          _ok = __gather_up_leading_non_identifier_lines
          _ok && begin

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

            @p = method :_node_via_just_after_node_identifier
            _node_via_just_after_node_identifier
          end
        end

        def __gather_up_leading_non_identifier_lines

          begin

            if @reinterpret_ID[ @ID ]
              x = ACHIEVED_
              break
            end

            s = @line_upstream.gets
            if s
              @sstr_a.push @Substring.new nil, nil, @scn.string
              @scn.string = s
              redo
            end
            break
          end while nil
          x
        end

        def _node_via_just_after_node_identifier

          @business_line_range_end = nil
          @start_new_node[]
          __accept_first_node_line
          begin
            s = @line_upstream.gets
            if ! s
              x = _EOF
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
            s = @line_upstream.gets
            if ! s
              x = _EOF
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

        def _node

          _reinitialize_node
          id = @ID
          @ID = @ID_
          @ID_ = id
          @node
        end

        def _EOF

          _reinitialize_node
          @p = EMPTY_P_
          @node
        end

        def _reinitialize_node

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

        WHITE__ = /[ \t]+/
      end
    end
  end
end
# :+#tombstone: "the embodiment of [#059] scanners"
