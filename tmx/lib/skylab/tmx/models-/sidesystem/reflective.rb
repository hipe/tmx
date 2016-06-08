module Skylab::TMX

  module Models_::Sidesystem

    # <-

  class Reflective

    class << self
      def via_load_ticket lt
        new lt
      end
      private :new
    end

    def initialize load_ticket

      @_lt = load_ticket
      @mod = @_lt.require_sidesystem_module
      @_nf = Common_::Name.via_module @mod
    end

    # ~ dependency inference

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

    # ~ reflection of "library"

    def has_library_node
      @___library_known_is_known ||= __know_library
      @_has_library_node
    end

    def __know_library  # (was [#sli-152]

      _yes = @mod.const_get :Lib_, false  # to be sure
      @_has_library_node = _yes ? true : false
      ACHIEVED_
    end

    # so it appears what's going on here is .. ah.

    def to_inferred_library_item_symbol_stream  # assume has lib node

      _lib_path = __whichever_lib_path

      fh = ::File.open _lib_path, ::File::RDONLY

      _line_st = Common_.stream do
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

      @__lib_path ||= __determine_the_PATH_to_the_lib
    end

    def __determine_the_PATH_to_the_lib

      # so this is hacky af - we need to read the file "by hand"

      code_root = @mod.dir_pathname.to_path

      try_deep = "#{ code_root }/lib-#{ Autoloader_::EXTNAME }"

      if ::File.exist? try_deep
        try_deep

      else

        try_deep = "#{ code_root }#{ Autoloader_::EXTNAME }"

        if ::File.exist? try_deep
          try_deep
        else
          fail __say_misbehaving
        end
      end
    end

    def __say_misbehaving
      "autoloader is probably not configured right: #{ @mod }"
    end

    # ~ readers

    def const
      @_nf.as_const
    end

    def path_to_gem
      @_lt.path_to_gem
    end

    def stem
      @_lt.stem
    end
  end
# ->
  end
end
