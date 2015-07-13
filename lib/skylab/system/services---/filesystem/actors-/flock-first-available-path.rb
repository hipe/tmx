module Skylab::System

  class Services___::Filesystem

    class Actors_::Flock_first_available_path  # :[#002].

      class << self

        def for_mutable_args_ x_a, & oes_p

          oes_p and raise ::ArgumentErrror

          case 1 <=> x_a.length
          when -1
            require 'byebug' ; send :"byeb#{}ug" ; 1==1 && :hyebug
          when 0
            self._K
          when 1
            self
          end
        end

        def call_with * x_a

          new( x_a ).execute
        end

        private :new
      end  # >>

      # ->

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
            f.flock ::File::LOCK_EX | ::File::LOCK_NB
            break
          end while nil
          f
        end

        # <-
    end
  end
end
