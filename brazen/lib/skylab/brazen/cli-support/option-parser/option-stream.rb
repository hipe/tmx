module Skylab::Brazen

  module CLI_Support

    class Option_Parser::Option_stream  # see [#095]

      Callback_::Actor.call self, :properties,
        :x

      def initialize
        super
        @pass_p ||= Default_pass__
      end

      def execute

        ea = __produce_some_enumerator

        Callback_.stream do

          begin
            begin

              sw = ea.next
              sw or redo

              _b = @pass_p[ sw ]
              _b or redo

              x = sw
              break

            rescue ::StopIteration
              break
            end

            redo
          end while nil

          x
        end
      end

      Default_pass__ = -> sw do

        _found = ! SHORT_LONG_I_A__.detect do | sym |
          ! sw.respond_to? sym
        end

        if _found

          SHORT_LONG_I_A__.detect do | sym |
            x = sw.send sym
            x or next
            x.length.nonzero?
          end
        end
      end

      SHORT_LONG_I_A__ = [ :short, :long ].freeze

      def __produce_some_enumerator

        if @x.respond_to? :each
          @x
        else
          __build_enumerator
        end
      end

      def __build_enumerator

        ::Enumerator.new do |y|

          @x.send :visit, :each_option do |sw|
            y << sw
          end
          NIL_
        end
      end
    end
  end
end
