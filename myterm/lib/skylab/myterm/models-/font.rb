module Skylab::MyTerm

  class Models_::Font

    # -- Construction methods

    class << self

      def interpret_component st, acs, & oes_p

        if st.no_unparsed_exists
          new nil, acs, & oes_p
        else
          new( st.gets_one, acs, & oes_p ).__normalize
        end
      end

      def __new_flyweight
        allocate
      end

      alias_method :new_entity, :new
      private :new
    end  # >>

    # -- Initializers

    def initialize x, ke_source, & oes_p

      @_do_express_skipped = true  # eew - avoid repetition here

      @kernel_ = ke_source.kernel_

      @_oes_p = oes_p

      @path = x  # any
    end

    # ~ (experimental flyweightism)

    def __reinit path
      @path = path ; self
    end

    # -- Expressive event & modality hook-ins/hook-outs

    def express_into_under y, expag
      self._RESPOND_TO_ONLY
    end

    def express_of_via_into_under y, _expag
      -> me do
        y << me.path
      end
    end

    def describe_into_under y, _
      y << "set font, list available fonts"
    end

    def description_under expag

      s = ::File.basename @path
      expag.calculate do
        val s
      end
    end

    # -- ACS hook-ins

    def to_primitive_for_component_serialization
      @path
    end

    # -- Operations

    # ~ the "set" operation

    def __set__component_operation

      yield :description, -> y do
        y << 'change what font is currently set'
      end

      method :__set
    end

    def __set path

      path_ = _lookup :set, path

      if path_

        _new_self = self.class.new_entity path_, self, & @_oes_p

        @_oes_p.call :change do
          _new_self
        end  # result is result
      else
        path_
      end
    end

    def __normalize  # assume path is set

      path = _lookup :normalize, @path
      if path
        @path = path
        self
      else
        ok
      end
    end

    def _lookup action_sym, path

      _oes_p = -> * i_a, & ev_p do

        _context = Begin_context_[ action_sym, ev_p[] ]

        @_oes_p.call( * i_a ) do
          _context
        end
      end

      o = Brazen_::Collection::Common_fuzzy_retrieve.new( & _oes_p )

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
        fly = self.class.__new_flyweight
        _to_path_stream.map_by do | path |
          fly.__reinit path
        end
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

      _glob_path = "#{ fonts_dir }/*"

      _paths = @_sys.filesystem.glob _glob_path

      remove_instance_variable :@_sys

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
        else
          NIL_  # currently ..
        end
      end
    end

    # -- Project hook-outs

    protected = [
      :kernel_,
      :path,
    ]

    attr_reader( * protected )
    protected( * protected )
  end
end
