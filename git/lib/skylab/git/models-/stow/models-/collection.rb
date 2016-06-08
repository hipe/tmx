module Skylab::Git

  class Models_::Stow

    class Models_::Collection

      # model a collection of "stows". in implementation, this means that
      # this models a directory that contains nothing but other directories.

      def initialize path, fs, k, & p

        @filesystem = fs
        @kernel = k
        @on_event_selectively = p
        @path = path
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
          __when_not_found name_s
        end
      end

      def __when_not_found name_s

        _stow = Stow_.new_via_path ::File.join( @path, name_s )

        _ev = Home_.lib_.brazen.event( :Component_Not_Found ).new_with(
          :component, _stow,
          :component_association, Stow_.name_function,
          :ACS, self,
        )

        @on_event_selectively.call :error, :component_not_found do
          _ev
        end

        UNABLE_
      end

      def to_entity_stream

        _dac = Home_.lib_.system_lib::Filesystem::Directory::As::Collection.new do |o|

          o.directory_path = @path
          o.directory_is_assumed_to_exist = true  # so it whines

          o.filesystem = @filesystem
          o.flyweight_class = Stow_

          o.kernel = @kernel

          o.on_event_selectively = @on_event_selectively
        end

        _dac.to_entity_stream_via_model( Stow_, & @on_event_selectively )
      end

      def produce_available_identifier name, & oes_p

        if RX___ =~ name

          id = ID___.new ::File.join( @path, name ), name

          if @filesystem.exist? id.path
            __when_exist id, & oes_p
          else
            id
          end
        else
          __when_invalid_chars name, & oes_p
        end
      end

      ID___ = ::Struct.new :path, :name

      RX___ = /\A [_a-z0-9]+ (?: - [_a-z0-9]+ )* \z/ix

      def __when_invalid_chars name, & oes_p

        oes_p.call :error, :expression, :invalid_stow_name do | y |

          y << "stow name contains invalid characters: #{ ick name }"
        end
        UNABLE_
      end

      def __when_exist id, & oes_p

        oes_p.call :error, :expression, :name_collision do | y |

          y << "a stow already exists with that name: #{ pth id.path }"
        end
        UNABLE_
      end

      # ~ for [#ac-007] expressive events

      def description_under expag

        path = @path
        expag.calculate do
          pth path
        end
      end

      nf = nil
      define_method :name do
        nf ||= Common_::Name.via_variegated_symbol :stows_collection
      end
    end
  end
end
