module Skylab::Common

  module Autoloader

    module ComponentModels__

      class Pedigree

        class << self

          def via_module__ mod

            s_a = mod.name.split CONST_SEPARATOR

            const_s = s_a.pop

            _parent_module = if s_a.length.nonzero?
              Const_value_via_parts[ s_a ]
            end

            new const_s, _parent_module
          end

          def via_module_and_parent_module__ mod, pmod

            name = mod.name
            d = name.rindex ':'  # COLON_
            _const_s = name[ d+1 .. -1 ]
            new _const_s, pmod
          end

          private :new
        end  # >>

        def initialize const_s, pmod
          @node_path_entry_name_ = Name.via_valid_const_string_ const_s
          @parent_module__ = pmod
        end

        attr_reader(
          :node_path_entry_name_,
          :parent_module__,
        )
      end

      # ==

      module Touch_dir_path ; class << self

        # if the instance variable is set and trueish, use that. otherwise
        # we'll try to derive your dir path using a dir path of your parent
        # module and your name. it's possible that you don't have a parent
        # module. if you do, it's possible that it doesn't expose a dir path
        # method. if it does, it's possible that it produces a false-ish
        # value (i.e none or unknown).

        def [] mod
          if mod.instance_variable_defined? NODE_PATH_IVAR_
            if ! mod.instance_variable_get NODE_PATH_IVAR_
              _descend mod
            end
          else
            _descend mod
          end
          ACHIEVED_  # must always be this
        end

        def _descend mod

          parent_mod = mod.parent_module
          if parent_mod
            if parent_mod.respond_to? NODE_PATH_METHOD_
              dir = parent_mod.dir_path
              if dir
                __via_parent_directory dir, mod
              else
                self._COVER_ME_directory_was_falseish
              end
            else
              raise ::NoMethodError, Here_::Say_::Needs_dir_path[ parent_mod ]
            end
          else
            self._COVER_ME_no_parent_module
          end
          NIL
        end

        def __via_parent_directory dir, mod

          _slug = mod.pedigree_.node_path_entry_name_.as_slug
          _node_path = ::File.join dir, _slug
          mod.instance_variable_set NODE_PATH_IVAR_, _node_path
          NIL
        end
      end ; end
    end
  end
end
