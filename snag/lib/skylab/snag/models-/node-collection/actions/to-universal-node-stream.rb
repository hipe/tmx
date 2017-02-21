self._NOT_COVERED_AND_GROWING_OLD

module Skylab::Snag

  class Models_::NodeCollection

    class Actions::To_Universal_Node_Stream  # [#001].

      class << self
        alias_method :new, :orig_new
      end

      # this is not integrated for now, we are just getting the
      # body of it to work under a visual test

      def sout_serr o, e

        @e = e ; @o = o

        expag = -> do
          x = Home_::CLI::InterfaceExpressionAgent.new
          expag = -> { x }
          x
        end

        @_oes_p = -> sym, * i_a, & ev_p do
          ev = ev_p[]
          if :info != sym
            e.write "error: "
          end
          ev.express_into_under e, expag[]
          :info == sym ? NIL_ : UNABLE_
        end

        NIL
      end

      def argv dir
        @dir = dir
        NIL_
      end

      def execute

        ok = __resolve_path
        ok &&= __via_path_resolve_manifest_stream
        ok &&= __via_manifest_stream_resolve_node_stream
        ok && __via_node_stream
      end

      def __resolve_path

        @fn = COMMON_MANIFEST_FILENAME_

        path = Walk_upwards_to_find_nearest_surrounding_path_[
          @dir, @fn, self._FILESYSTEM, & @_oes_p ]

        if path
          @_path = path
          ACHIEVED_
        else
          path
        end
      end

      self._WHAT
      alias_method :execute, :execute

      def __via_path_resolve_manifest_stream

        _sidesystems = ::File.dirname @_path

        _s_a = ::Dir.glob ::File.join( _sidesystems, "*/#{ @fn }" )

        @_mani_st = Common_::Stream.via_nonsparse_array _s_a do | path |

           Models_::NodeCollection.new_via_path path, & @_oes_p
        end

        ACHIEVED_
      end

      def __via_manifest_stream_resolve_node_stream

        st = __via_manifest_stream_build_node_stream
        if st
          @_node_st = st
          ACHIEVED_
        else
          st
        end
      end

      def __via_manifest_stream_build_node_stream

        bn = ::File.method :basename
        dn = ::File.method :dirname

        @_mani_st.expand_by do | mani |


          @e.puts "# #{ bn[ dn[ dn[ mani.upstream_identifier.to_path ] ] ] }"

          mani.to_entity_stream
        end
      end

      def __via_node_stream  # one day we will expand this to criteria

        focus_count = 0
        total_count = 0

        expag = Models_::NodeCollection::ExpressionAdapters::ByteStream.
          build_default_expression_agent

        st = @_node_st
        begin
          node = st.gets
          node or break
          total_count += 1

          if node.is_tagged_with :open
            focus_count += 1
            node.express_into_under @o, expag
          end

          redo
        end while nil

        @e.puts "(#{ focus_count } of #{ total_count } nodes open)"

        ACHIEVED_
      end
    end
  end
end
