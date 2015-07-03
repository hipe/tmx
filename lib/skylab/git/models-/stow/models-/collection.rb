module Skylab::Git

  class Models_::Stow

    class Models_::Collection

      # model a collection of "stows". in implementation, this means that
      # this models a directory that contains nothing but other directories.

      def initialize path, k, & p

        @kernel = k
        @path = path
        @on_event_selectively = p
      end

      def entity_via_intrinsic_key name_s

        st = to_entity_stream
        begin
          stow = st.gets
          stow or break
          if name_s == stow.get_stow_name
            break
          end
          redo
        end while nil

        if stow
          stow
        else
          self._COVER_ME
        end
      end

      def to_entity_stream

        _dac =
        Bz__::Collection_Adapters::Directory_as_Collection.new( @kernel ) do | o |

          o.directory_path = @path
          o.directory_is_assumed_to_exist = true  # so it whines

          o.filesystem = Home_.lib_.system.filesystem
          o.flyweight_class = Stow_

          o.on_event_selectively = @on_event_selectively
        end

        _dac.to_entity_stream_via_model( Stow_, & @on_event_selectively )
      end
    end
  end
end
