module Skylab::Basic

  module String

      class Yamlizer__  # for now covered by [sg]  #todo

        Callback_::Actor.call self, :properties,
          :output_line_yielder,
          :field_names

        def initialize
          super
          init_format
        end

      private

        def init_format
          _maxlen = @field_names.reduce( 0 ) do |m, i|
            x = i.to_s.length
            m > x ? m : x
          end
          @fmt = "%-#{ _maxlen }s" ; nil
        end

      public

        def << pairs
          @output_line_yielder << BAR__
          pairs.each_pair do |i, s|
            @output_line_yielder << "#{ @fmt % i } : #{ s }"
          end
          self
        end

        BAR__ = '---'.freeze
      end

  end
end
