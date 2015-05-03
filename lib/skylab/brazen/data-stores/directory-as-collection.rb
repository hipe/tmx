module Skylab::Brazen

  class Data_Stores::Directory_as_Collection

    class << self
      def is_actionable
        false
      end
    end  # >>

    def initialize k

      @directory_is_assumed_to_exist = true
      @filename_pattern = nil
      @_kernel = k

      if block_given?
        yield self
      end
    end

    attr_writer(
      :directory_is_assumed_to_exist,
      :directory_path,
      :filesystem,
      :filename_pattern,  # respond to `=~`
      :flyweight_class
    )

    def to_entity_stream_via_model _cls_, & x_p  # #UAO
      to_entity_stream( & x_p )
    end

    def to_entity_stream & x_p

      p = -> do

        path_a = __produce_path_a
        if path_a
          p = __proc_via_path_a path_a, & x_p
          p[]
        else
          path_a
        end
      end

      Callback_.stream do
        p[]
      end
    end

    def __produce_path_a

      path = @directory_path
      if path  # otherwise nasty

        glob = -> do
          @filesystem.glob ::File.join( path, '*' )
        end

        if @directory_is_assumed_to_exist
          glob[]
        else
          if @filesystem.directory? path
            glob[]
          else
            EMPTY_A_
          end
        end
      else
        UNABLE_
      end
    end

    def __proc_via_path_a path_a, & x_p

      fly = @flyweight_class.new_flyweight @_kernel, & x_p

      pass = __produce_pass_proc

      st = Callback_::Stream.via_nonsparse_array(
        path_a
      ).map_reduce_by do | path_ |

        _yes = pass[ path_ ]
        if _yes

          fly.reinitialize_via_path_for_directory_as_collection path_
          fly
        end
      end

      -> do
        st.gets
      end
    end

    def __produce_pass_proc

      if @filename_pattern
        rx_ish = @filename_pattern
        -> path do
          rx_ish =~ ::File.basename( path )
        end
      else
        MONADIC_TRUTH_
      end
    end

    MONADIC_TRUTH_ = -> _ { true }
  end
end
