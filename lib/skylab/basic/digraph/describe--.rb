module Skylab::Basic

  class Digraph

    class Describe__

      Basic_::Lib_::Iambic_parameters[ self, :params,
        :IO,
        :with_solos, %i( argument_arity zero ivar @do_solos ),
        :with_spaces, %i( argument_arity zero ivar @do_spaces ) ]

      def initialize g, x_a
        nilify_and_absorb_iambic_fully x_a
        @associations = g.send :node_assctns
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
          @IO_was_provided = true ; @io = @IO
        else
          @IO_was_provided = false ; @io = Basic_::Lib_::String_IO[]
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
        @associations.each do |source_i, target_i|
          target_i && @do_solos and @see_target_i_p[ target_i ]
          write_line "#{ source_i }#{ "#{ @sep }#{ target_i }" if target_i }"
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
