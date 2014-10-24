module Skylab::Headless

  module CLI::Option__

    module Parser__  # ~ stowaway

      class << self

        def enumerator op
          scan( op ).each
        end

        def recorder & p
          Recorder__.new p
        end

        def scanner op
          Parser_::Scanner__[ op ]
        end
      end

      Recorder__ = Headless_::Lib_::Ivars_with_procs_as_methods[].new :on, :@on, :define do

        def initialize option_p
          @on = -> * a, & p  do
            option_p[ Option_.on( * a, & p ) ]
            nil
          end
        end
      end

      Parser_ = self
    end
  end
end
