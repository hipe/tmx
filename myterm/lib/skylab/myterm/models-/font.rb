module Skylab::MyTerm

  class Models_::Font

    class << self

      def interpret_component st, acs, & oes_p

        if st.no_unparsed_exists
          new nil, acs, & oes_p
        else
          new( st.gets_one, acs, & oes_p ).___normalize
        end
      end

      alias_method :new_entity, :new
      private :new
    end  # >>

    def initialize x, ke_source, & oes_p

      @_do_express_skipped = true  # eew - avoid repetition here

      @kernel_ = ke_source.kernel_

      @_oes_p = oes_p

      @path = x  # any
    end

    # -- Operations --

    # ~ the "set" operation

    def __set__component_operation

      yield :description, -> y do
        y << 'change what font is currently set'
      end

      method :__set
    end

    def __set path

      path_ = _lookup path

      if path_

        _new_self = self.class.new_entity path_, self, & @_oes_p

        @_oes_p.call :component, :change do | y |

          y.yield :new_component, _new_self
        end  # result is result
      else
        path_
      end
    end

    def ___normalize  # assume path is set

      path = _lookup @path
      if path
        @path = path
        self
      else
        ok
      end
    end

    def _lookup path

      oes_p = @_oes_p

      o = Brazen_::Collection::Common_fuzzy_retrieve.new( & oes_p )

      o.set_qualified_knownness_value_and_symbol path, :font_path

      o.stream_builder = -> do
        _to_path_stream
      end

      p = -> path_ do
        ::File.basename( path_ ).downcase
      end

      o.name_map = p
      o.target_map = p

      o.levenshtein_number = 3

      o.execute
    end

    # ~ the "list" operation

    def __list__component_operation

      yield :description, -> y do
        y << 'hackishly list the known fonts'
      end

      -> do
        _to_path_stream
      end
    end

    def _to_path_stream

      @_sys = @kernel_.silo :Installation

      real_yes = __build_pass_filter

      none = true
      yes = -> x do
        yep = real_yes[ x ]
        if yep
          none = false
          yes = real_yes
        end
        yep
      end

      fonts_dir = @_sys.fonts_dir

      remove_instance_variable :@_sys

      _paths = ::Dir[ "#{ fonts_dir }/*" ]

      _st = Callback_::Stream.via_nonsparse_array _paths

      skipped = nil
      none = false

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
          if none
            @_oes_p.call :info, :expression, :not_found do | y |
              y << "(no fonts found - #{ pth fonts_dir })"
            end
          end
          if skipped && @_do_express_skipped
            @_do_express_skipped = false
            @_oes_p.call :info, :expression, :skipped do | y |
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

    # ~ the "get" operation

    def __get__component_operation

      yield :description, -> y do
        y << "result in any 'font' object that is currently selected"
      end

      -> do
        if @path
          self
        end
      end
    end

    # -- ACS [reactive tree] hook-out's/hook-ins --

    def describe_into_under y, _
      y << "set font, list available fonts"
    end

    def description_under expag

      s = ::File.basename @path
      expag.calculate do
        val s
      end
    end

    def to_primitive_for_component_serialization
      @path
    end

    attr_reader :kernel_
    protected :kernel_
  end
end
