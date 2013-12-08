module Skylab::Headless

  module CLI::Client::Adapter::For

    module Face

      module Of

        # this is adapter for face of hot :[#082]

        Hot = -> ns_sheet, client_mod do
          -> mechanics, _token_used do
            Hot_Adapter_.new ns_sheet, client_mod, mechanics
          end
        end

        class Hot_Adapter_ < ::Skylab::Face::CLI::Adapter::For::Face::Of::Hot

          def get_summary_a_from_sheet _ns_sheet
            [ @actual.summary_line ]
          end
        end
      end
    end
  end
end
