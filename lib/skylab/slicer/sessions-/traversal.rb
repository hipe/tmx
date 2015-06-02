module Skylab::Slicer

  Sessions_ = ::Module.new

  class Sessions_::Traversal

    def to_sidesystem_stream

      _path_a = ::Dir[ "#{ ::Skylab.dir_pathname.to_path }/*/core.rb" ]  # :+[#118]
      _st = Callback_::Stream.via_nonsparse_array _path_a

      _st.map_reduce_by do | path |

        ss = __begin_sidesystem_via_path path
        if ss.mod
          ss
        end
      end
    end

    def __begin_sidesystem_via_path path

      ss = Slicer_::Models_::Sidesystem.new
      ss.norm = ::File.dirname path
      ss.stem = ::File.basename ss.norm
      _mod = Autoloader_.const_reduce [ ss.stem ], ::Skylab do end
      ss.receive_any_module _mod
      ss
    end
  end
end
