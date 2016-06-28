module Skylab::DocTest

  module Operations_

    class Synchronize

      # (will rewrite..)

      _hi = -> y do

            a = Home_.get_output_adapter_slug_array_

            a.map!( & method( :highlight ) )

            y << "available adapter#{ s a }: {#{ a * ' | ' }}. when used in"
            y << "conjunction with help, more options may appear."
      end

        def ___resolve_output_adapter_module

          mod = Autoloader_.const_reduce(
            [ @output_adapter ],  # nil ok
            Home_::OutputAdapters_,
            & @on_event_selectively )

          if mod
            @output_adapter_module = mod
            ACHIEVED_
          else
            mod
          end
        end
    end
  end
end
# #tombstone: lots of old code and compatible comment examples
