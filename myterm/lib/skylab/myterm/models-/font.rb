module Skylab::MyTerm

  class Models_::Font

    class << self
      def interpret_component st, & oes_p

        if st.no_unparsed_exists
          new( & oes_p )
        else
          self._K_needs_kernel
        end
      end
      private :new
    end  # >>

    def initialize & oes_p
      @_oes_p = oes_p
    end

    def initialize_component asc, _APPEARANCE_acs
      @_asc = asc
      @_kernel = _APPEARANCE_acs.kernel_
    end

    def __list__component_operation

      yield :description, -> y do
        y << 'hackishly list the known fonts'
      end

      method :__to_path_stream
    end

    def __to_path_stream

      @_sys = @_kernel.silo :Installation

      yes = __build_pass_filter

      _path = @_sys.fonts_dir

      remove_instance_variable :@_sys

      _paths = ::Dir[ "#{ _path }/*" ]

      _st = Callback_::Stream.via_nonsparse_array _paths

      skipped = nil
      st = _st.reduce_by do | path |

        if yes[ path ]
          path
        else
          skipped ||= ::Hash.new 0
          skipped[ ::File.extname( path ) ] += 1
          NIL_
        end
      end

      p = -> do
        x = st.gets
        if x
          x
        else
          if skipped
            @_oes_p.call :info, :expression do | y |
              y << "(skipped: #{ skipped.inspect })"
            end
          end
          p = ->{};  # EMPTY_P_
          NIL_
        end
      end

      Callback_::Stream.new do
        p[]
      end
    end

    def __build_pass_filter

      _a = @_sys.get_font_file_extensions

      h = ::Hash[ _a.map { |s| [ ".#{ s }", true ] } ]

      -> path do
        h[ ::File.extname( path ) ]
      end
    end

    # ~

    def describe_into_under y, _
      y << "set font, list available fonts"
    end
  end
end
