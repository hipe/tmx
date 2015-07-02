module Skylab::Brazen

  class CLI

    # ~ #comport:face this whole file. (just to fit in 'tmx')

    module Client

      module Adapter
        module For
          module Face
            module Of
              Hot = -> x, x_ do
                Client.fml Home_, x, x_
              end
            end
          end
        end
      end

      class << self

        def fml ss_mod, ns_sheet, my_CLI_class

          -> strange_kernel, any_invo_s do

            FML___.
              new ss_mod, ns_sheet, my_CLI_class, strange_kernel, any_invo_s

          end
        end
      end  # >>

      class FML___

        def initialize *a

          @my_SS_mod, @NS_sheet, _my_CLI_class,
            @strange_kernel, _given_slug = a

        end

        def get_summary_a_from_sheet sht
        end

        def get_autonomous_quad argv

          # the below isn't always the same as `_my_CLI_class` above

          [ @my_SS_mod::CLI.new( *

              @strange_kernel.three_streams,
              @strange_kernel.get_normal_invocation_string_parts ) ,

            :invoke,

            [ argv ],

            nil ]
        end

        def is_autonomous
          true
        end

        def is_visible
          true
        end

        def name
          @NS_sheet.name
        end

        def pre_execute
          self
        end
      end
    end
  end
end
