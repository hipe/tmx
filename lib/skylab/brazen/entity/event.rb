module Skylab::Brazen

  module Entity

    class Event

      def initialize x_a, p
        @message_proc = p
        scn = Iambic_Scanner.new 0, x_a
        @terminal_channel_i = scn.gets_one
        @ivar_box = Box_.new
        sc = singleton_class
        while scn.unparsed_exists
          i = scn.gets_one
          ivar = :"@#{ i }"
          @ivar_box.add i, ivar
          instance_variable_set ivar, scn.gets_one
          sc.send :attr_reader, i
        end ; nil
      end

      attr_reader :message_proc, :terminal_channel_i

      def has_member i
        @ivar_box.has_name i
      end

      def members
        @ivar_box.get_local_normal_names
      end

      def render_under expression_agent
        expression_agent.calculate self, & @message_proc
      end
    end
  end
end
