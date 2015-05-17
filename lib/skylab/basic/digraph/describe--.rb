module Skylab::Basic

  class Digraph

    class Describe__

      Callback_::Actor.methodic self, :simple, :properties,
        :property, :IO,
        :argument_arity, :zero, :ivar, :@do_solos, :property, :with_solos,
        :argument_arity, :zero, :ivar, :@do_spaces, :property, :with_spaces


      def initialize g, x_a
        process_polymorphic_stream_fully polymorphic_stream_via_iambic x_a
        nilify_uninitialized_ivars
        @association_st = g.to_node_edge_stream_
        init_IO
        @is_first_line = true  # (write the newlines at the beginning not end for reasons)
        @sep = @do_spaces ? ARROW__ : ARW__
        @do_solos and init_solo_h
        init_write_line_p
      end
      ARW__ = '->'.freeze
      ARROW__ = " #{ ARW__ } ".freeze
    private
      def init_IO
        if @IO
          @IO_was_provided = true
          @io = @IO
        else
          @IO_was_provided = false
          @io = Basic_.lib_.string_IO
        end  ; nil
      end
      def init_solo_h
        @see_target_i_p = ::Hash.new do |h, k|
          write_line k
          h[ k ] = true ; nil
        end ; nil
      end
      def init_write_line_p
        @write_line_p = -> x do
          @io.write "#{ x }"
          @is_first_line = false
          @write_line_p = -> x_ do
            @io.write "\n#{ x_ }" ; nil
          end ; nil
        end ; nil
      end
    public
      def execute
        st = @association_st
        assoc = st.gets
        while assoc
          source_i, target_i = assoc.to_a
          target_i && @do_solos and @see_target_i_p[ target_i ]
          write_line "#{ source_i }#{ "#{ @sep }#{ target_i }" if target_i }"
          assoc = st.gets
        end
        @is_first_line and write_line "# (empty)"
          # i don't love this, but you could always check `node_count`
        finish
      end
    private
      def write_line x
        @write_line_p[ x ]
      end
      def finish
        if ! @IO_was_provided
          @io.rewind
          @io.read
        end
      end
    end
  end
end
