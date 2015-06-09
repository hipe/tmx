module Skylab::Slicer

  class Models_::Sidesystem  # :+[#ts-041]

    Actions = THE_EMPTY_MODULE_

    attr_accessor :mod, :const, :deps, :medo, :norm, :stem

    attr_reader :lib_path

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

    def find_library

      @lib_path = nil

      if @mod.respond_to? :lib_
        @mod.lib_

        lib_path = "#{ @norm }/lib-#{ Autoloader_::EXTNAME }"

        if ::File.exist? lib_path
          @lib_path = lib_path
        else
          lib_path = "#{ @norm }/library-#{ Autoloader_::EXTNAME }"
          if ::File.exist? lib_path
            @lib_path = lib_path
          else
            @lib_path = "#{ @norm }/core#{ Autoloader_::EXTNAME }"
          end
        end
      end

      @lib_path && true
    end

    def inferred_dependencies  # assume lib_path

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

    def to_inferred_library_item_symbol_stream

      fh = ::File.open @lib_path, ::File::RDONLY

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

  end
end
