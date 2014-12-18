module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Recursive

        class Models__::File_Generation

          Parameter_Functions__::Output_filename = -> gen, val_x do

            _current_path = gen.output_path
            _dirname = ::File.dirname _current_path
            _new_path = ::File.join _dirname, val_x

            gen.receive_output_path _new_path
          end
        end
      end
    end
  end
end
