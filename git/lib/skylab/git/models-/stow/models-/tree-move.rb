module Skylab::Git

  class Models_::Stow

    class Models_::Tree_Move

      # an implementation of "unit of work" pattern,

      # model the request data that is involved in a filesystem operation
      # whereby files A, B, C [..] would be moved ("renamed") from source
      # directory S to destination directory D.
      #
      # A, B, C [..] must be relative paths, and S and D must be absolute
      # paths. as such, this models a series of file node renames whereby
      # some structure is carried across from source to destination (even
      # if only one level deep).
      #
      # S and D cannot have a parent-child relationship in either
      # direction.
      #
      # whether or S and D represent existent directories on the filesystem
      # at any moment IS..
      #
      # the extent to which the subject does or does not implement the
      # actual moving is peripheral to its main responsibilty: to model
      # the argument data of such an operation. (that is why we chose to
      # house this node under "models" and not "sessions" was to drive
      # home this point.)
      #

      def initialize src_path, dst_path

        @a = []

        @source_path = _verify_as_absolute( src_path ).value_x

        @destination_path = _verify_as_absolute( dst_path ).value_x

      end

      def each_path_pair

        st = to_source_path_stream
        st_ = to_destination_path_stream

        begin
          path = st.gets
          path_ = st_.gets
          if path
            if path_
              yield path, path_
            else
              self._SANITY
            end
          elsif path_
            self._SANITY
          else
            break
          end
          redo
        end while nil
        NIL_
      end

      def each_source_path( & p )

        to_source_path_stream.each( & p )
      end

      def each_destination_path( & p )

        to_destination_path_stream.each( & p )
      end

      def to_source_path_stream

        _to_path_stream_around @source_path
      end

      def to_destination_path_stream

        _to_path_stream_around @destination_path
      end

      def _to_path_stream_around path

        Common_::Stream.via_nonsparse_array( @a ).map_by do | relpath |

          ::File.join path, relpath
        end
      end

      def add path

        @a.push _normalize_relative( path ).value_x
        NIL_
      end

      define_method :_verify_as_absolute, -> do

        p = -> path do

          n18n = Home_.lib_.basic::Pathname.normalization.with(
            :absolute,
            :downward_only,
            :no_single_dots,
          )
          p = -> path_ do

            n18n.normalize_value path_
          end
          p[ path ]
        end

        -> path do
          p[ path ]
        end
      end.call

      define_method :_normalize_relative, -> do

        p = -> path do

          n18n = Home_.lib_.basic::Pathname.normalization.with(
            :relative,
            :downward_only,
          )
          p = -> path_ do

            n18n.normalize_value path_
          end
          p[ path ]
        end

        rx = / (?<= \A \. \/ )  .*  \z/mx

        -> path do
          o = p[ path ]
          if o
            md = rx.match o.value_x
            if md
              o.new_with_value md[ 0 ]
            else
              o
            end
          else
            o
          end
        end
      end.call

      def execute sym=nil, fs, & x_p

        Stow_::Actors_::Move_Tree.new( self, sym, fs, & x_p ).execute
      end

      attr_reader(
        :a,
        :destination_path,
        :source_path,
      )
    end
  end
end
