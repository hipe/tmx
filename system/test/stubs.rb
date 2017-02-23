module Skylab::System

  module TestSupport::STUBS  # :[#024].

    class << self

      def noninteractive_STDIN_class

        Nonteractive_Stdin___
      end

      def interactive_STDIN_instance

        @__IS ||= Stdin__.new true
      end

      def noninteractive_IO_instance

        @__NI ||= IO__.new false
      end

      def noninteractive_STDIN_instance

        @__NS ||= Stdin__.new false
      end

      def successful_wait
        @___sw ||= Home_::Doubles::Stubbed_System::Stubbed_Thread.new 0
      end
    end  # >>

    class IO__

      def initialize yes
        @_is_tty = yes
      end

      def tty?
        @_is_tty
      end
    end

    class Stdin__ < IO__

      def closed?
        false  # a.l.a.i.w
      end
    end

    class Nonteractive_Stdin___

      class << self

        def via_lines s_a
          new s_a
        end

        private :new
      end  # >>

      attr_reader :lineno

      def initialize s_a

        @_is_closed = false

        if s_a
          @lineno = 0
          @_st = Common_::Stream.via_nonsparse_array( s_a ) do | s |
            if s
              @lineno += 1
            end
            s
          end
        end
      end

      def closed?
        @_is_closed
      end

      def gets
        @_st.gets
      end

      def tty?
        false
      end
    end
  end
end
