module Skylab::Headless

  module CLI::Option__

    class Scan__  # see [#168]

      Callback_::Actor[ self, :properties,
        :x ]

      def execute
        resolve_pass_proc
        resolve_enumerator
        Callback_.scan do
          while true
            begin
              sw = @enumerator.next
              sw or next
              _b = @pass_p[ sw ]
              _b or next
              switch = sw
              break
            rescue ::StopIteration
              break
            end
          end
          switch
        end
      end

    private

      def resolve_pass_proc
        @pass_p ||= Default_pass__
      end

      Default_pass__ = -> sw do

        ok = ! SHORT_LONG_I_A__.detect do |i|
          ! sw.respond_to? i
        end

        ok and SHORT_LONG_I_A__.detect do |i|
          x = sw.send i
          x and x.length.nonzero?
        end
      end

      SHORT_LONG_I_A__ = [ :short, :long ].freeze

      def resolve_enumerator
        if @x.respond_to? :each
          @enumerator = @x
        else
          @enumerator = build_enumerator
        end
      end

      def build_enumerator
        ::Enumerator.new do |y|
          @x.send :visit, :each_option do |sw|
            y << sw
          end ; nil
        end
      end
    end
  end
end
