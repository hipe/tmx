module Skylab::Snag

  class CLI

    class Expression_Agent_

      # subclass Snag_::Lib_::CLI[]::Pen::Minimal for less DIY

      def initialize retrieve_param
        @retrieve_param = retrieve_param
      end

      alias_method :calculate, :instance_exec

      h = { strong: 1, green: 32 }.freeze
      o = -> * i_a do
        fmt = "\e[#{ i_a.map { |i| h.fetch i } * ';' }m"
        -> x do
          "#{ fmt }#{ x }\e[0m"
        end
      end

      define_method :em, o[ :strong, :green ]

      define_method :h2, o[ :green ]

      define_method :ick, -> do
        p = -> x do
          p = Snag_::Lib_::Strange[].to_proc.
            curry[ A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_ ]
          p[ x ]
        end
        -> x { p[ x ] }
      end.call
      A_REASONABLY_SHORT_LENGTH_FOR_A_STRING_ = 15

      define_method :kbd, o[ :green ]

      def par i  # :+[#hl-036]
        param = @retrieve_param[ i ]
        if param.is_option
          param.as_parameter_signifier
        elsif param.is_argument
          "<#{ param.as_slug }>"
        end
      end

      def pth x
        Snag_::Lib_::Pretty_path[ x.to_path ]
      end

      def val x
        em x
      end

      # ~

      def and_ a
        prpnd ; and_ a
      end

      def or_ a
        prpnd ; or_ a
      end

      def s * a
        prpnd ; s( * a )
      end

      def prpnd
        self.class.prepend Prepend___[] ; nil
      end

      Prepend___ = -> do
        Prepend__ = ::Module.new.module_exec do
          Snag_::Lib_::EN_FUN[ self, :private, [ :and_, :or_, :s ] ]
          self
        end
      end
    end
  end
end
