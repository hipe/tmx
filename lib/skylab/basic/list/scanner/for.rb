module Skylab::Basic

  module List::Scanner

    module For

      def self.block & p

        Enumerator.new ::Enumerator.new( & p )

      end

      class Enumerator  # wrap an enumerator to act like a mimimal scanner

        def initialize enum
          @gets_p = -> do
            begin
              enum.next
            rescue ::StopIteration
              @gets_p = MetaHell::EMPTY_P_ ; nil
            end
          end
        end

        def gets
          @gets_p.call
        end
      end

      Path = -> path_x, * a do
        _open_filehandle = ::File.open "#{ path_x }", 'r'
        For::Read.new _open_filehandle, * a
      end
    end
  end
end
