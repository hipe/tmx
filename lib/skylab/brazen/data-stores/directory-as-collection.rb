module Skylab::Brazen

  class Data_Stores::Directory_as_Collection

    class << self
      def is_actionable
        false
      end
    end  # >>

    def initialize k
      @_kernel = k
      if block_given?
        yield self
      end
    end

    attr_writer :flyweight_class

    def to_entity_stream_via_model _cls_, & x_p  # #UAO
      to_entity_stream( & x_p )
    end

    def to_entity_stream & x_p

      p = -> do

        fly = @flyweight_class.new_flyweight @_kernel, & x_p

        _base_path = @flyweight_class.path_for_directory_as_collection

        _path_a = ::Dir.glob ::File.join( _base_path, '*' )

        __D = 0

        st = Callback_::Stream.via_nonsparse_array( _path_a ).map_by do | path |

          fly.reinitialize_via_path_for_directory_as_collection path
          fly
        end

        p = -> do
          st.gets
        end

        st.gets
      end

      Callback_.stream do
        p[]
      end
    end
  end
end
