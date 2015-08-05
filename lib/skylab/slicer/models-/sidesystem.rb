module Skylab::Slicer

  class Models_::Sidesystem  # :+[#ts-041]

    Actions = THE_EMPTY_MODULE_

    attr_accessor :mod, :const, :deps, :medo, :norm, :stem

    def get_core_path
      "#{ @norm }/core.rb"
    end

    def receive_any_module mod

      @mod = mod

      if mod
        s = mod.name
        d = s.rindex COLON___
        @const = s[ d + 1 .. -1 ].intern
      end
      nil
    end

    COLON___ = ':'

    def has_library_node
      @___library_known_is_known ||= __know_library
      @_has_library_node
    end

    def __know_library

      # although within the platform runtime we load any library module,
      # sadly to index each library node for sidesystems it is *better*
      # to do this via grepping for (codepoint) [#152] because..

      _yes = @mod.const_get :Lib_, false  # to be sure
      @_has_library_node = _yes ? true : false
      ACHIEVED_
    end

    def inferred_dependencies  # assume library node

      @___did_infer_deps ||= __infer_deps
      @_dependency_symbols
    end

    def __infer_deps

      st = to_inferred_library_item_symbol_stream
      sym = st.gets
      if sym
        sym_a = [ sym ]
        sym = st.gets
        while sym
          sym_a.push sym
          sym = st.gets
        end
        sym_a.freeze
      end

      @_dependency_symbols = sym_a

      ACHIEVED_
    end

    def to_inferred_library_item_symbol_stream  # assume has lib node

      _lib_path = __whichever_lib_path

      fh = ::File.open _lib_path, ::File::RDONLY

      _line_st = Callback_.stream do
        fh.gets
      end

      _line_st.map_reduce_by do | line |

        md = RX__.match line
        if md
          md[ 1 ].intern
        end
      end
    end

    RX__ = / = sidesys\[ :([A-Za-z0-9_]+) \]/

    def __whichever_lib_path  # assume has lib node

      @__lib_path ||= __determine_whichever_lib_path
    end

    def __determine_whichever_lib_path

      try_deep = "#{ @norm }/lib-#{ Autoloader_::EXTNAME }"

      if ::File.exist? try_deep
        try_deep
      else
        "#{ @norm }/core#{ Autoloader_::EXTNAME }"
      end
    end
  end
end
