module Skylab::Basic

  module Tree

    class Actors__::Fetch_or_touch

      # (client writes ivars directly - "highly coupled" performer interface)

      def initialize node, & edit_p

        @leaf_node_payload_proc = nil
        @node = node
        @result_tuple_proc = nil
        instance_exec( & edit_p )
      end

      def process_iambic_fully x_a
        st = Common_::Polymorphic_Stream.via_array x_a
        while st.unparsed_exists
          ivar = :"@#{ st.current_token }"
          if instance_variable_defined? ivar
            st.advance_one
            instance_variable_set ivar, st.gets_one
            next
          end
          raise ::ArgumentError
        end
        KEEP_PARSING_
      end

      def execute

        a = ___normal_path_array
        if a.length.zero?
          @node
        else
          @_slug_stream = Common_::Polymorphic_Stream.via_array a
          __main_loop_because_nonempty_slug_stream
        end
      end

      def ___normal_path_array

        path_a = ::Array.try_convert @path_x
        if path_a
          path_a
        else
          "#{ @path_x }".split @node.path_separator  #  :+#gigo
        end
      end

      def __main_loop_because_nonempty_slug_stream

        do_create = :touch == @fetch_or_touch
        node = @node
        st = @_slug_stream

        begin

          node_ = node[ st.current_token ]

          if node_
            st.advance_one
          elsif do_create
            node_ = ___add_child_because_touch node
          else
            x = __when_not_found st, node
            break
          end

          if st.unparsed_exists
            node = node_
            redo
          end

          x = __when_found node_
          break
        end while nil

        x
      end

      # internally this is an "interating performer" - those variables that
      # are immutable throughout are ivars, and those that change with each
      # iteration are passed around as parameters.

      def ___add_child_because_touch node

        slug = @_slug_stream.gets_one

        node_ = node.class.new slug

        # set the newly created node's payload using the most applicable
        # proc based on whether we are at the end and which were provided

        if @_slug_stream.no_unparsed_exists  # are we at the end?
          p = @leaf_node_payload_proc
        end

        if ! p
          p = @node_payload_proc
        end

        if p
          node_.set_node_payload p[]
        end

        node.add slug, node_
        node_
      end

      def __when_not_found st, node

        if @when_not_found
          __when_not_found_via_proc st, node
        else
          raise ::KeyError, ___say_no_such_node
        end
      end

      def ___say_no_such_node
        "no such node: '#{ @_slug_stream.current_token }'"
      end

      def __when_not_found_via_proc st, node

        p = @when_not_found
        d = p.arity
        if d.zero?
          p[]
        elsif 2 <= d
          p[ node, st ]
        else
          self._WRITE_ME_probably_oes
        end
      end

      def __when_found node
        p = @result_tuple_proc
        if p
          p[ node, @_slug_stream ]
        else
          node
        end
      end
    end
  end
end
