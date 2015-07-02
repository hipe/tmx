module Skylab::System


    class Services___::Filesystem

      class Flock_first_available_path__  # :[#002].

        class << self

          def call_with * x_a
            call_via_iambic x_a
          end

          def call_via_iambic x_a
            new( x_a ).execute
          end
        end  # >>


        def initialize x_a
          @x_a = x_a
        end

        def execute
          p = Home_.lib_.basic::String.succ.call_via_iambic @x_a
          begin
            path = p[]

            if ::File.exist? path
              redo
            end
            f = ::File.open path, ::File::RDWR | ::File::CREAT
            f.flock ::File::LOCK_EX
            break
          end while nil
          f
        end
      end
    end
end
