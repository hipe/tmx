module Skylab::SearchAndReplace

    class Magnetics_::Replace_Function_via_String_and_Work_Dir

      class Build_replace_expression__

        Callback_::Actor.call( self, :properties,

          :capture_identifier,
          :functions_dir,
          :method_call_chain,
        )

        def execute

          @method_call_chain = @method_call_chain.map( & :intern )

          @custom_i_a = @method_call_chain - BUILTIN_FUNCTION_NAMES__

          _ok = ___resolve_fulfiller
          _ok && __via_fulfiller
        end

        def ___resolve_fulfiller

          if @custom_i_a.length.zero?

            fu = BUILTIN_FUNCTIONS__

          elsif @functions_dir

            fu = Build_fulfiller___.call(
              @custom_i_a,
              @functions_dir,
              & @on_event_selectively )

          else
            fu = ___when_no_functions_directory
          end

          if fu
            @fulfiller = fu ; ACHIEVED_
          else
            fu
          end
        end

        def ___when_no_functions_directory

          sym_a = @custom_i_a

          @on_event_selectively.call(

            :error, :expression, :functions_directory_required

          ) do | y |

            _s_a = sym_a.map( & method( :code ) )

            y << "a `functions_directory` #{
              }must be indicated to help define #{
               }#{ _s_a * ' and ' }"
          end

          UNABLE_
        end

        def __via_fulfiller

          Replace_Expression___.new(
            @method_call_chain,
            @capture_identifier,
            @fulfiller,
          )
        end

        class Replace_Expression___

          # proof of concept class. currently not robust, secure, scalable

          def initialize * a
            @method_call_chain, capture_identifier, @fulfiller = a
            @d = capture_identifier.to_i
          end

          def marshal_dump
            "{{ $#{ @d }#{ @method_call_chain.map do |s|
              ".#{ s }"
            end.join EMPTY_S_ } }}"
          end

          alias_method :as_text, :marshal_dump

          def call md
            @method_call_chain.reduce md[ @d ] do | x, method_i |
              @fulfiller.__send__ method_i, x
            end
          end
        end

        class Builtin_Functions__ < ::BasicObject

          def downcase s
            s.downcase
          end

          def upcase s
            s.upcase
          end
        end

        BUILTIN_FUNCTIONS__ = Builtin_Functions__.new

        BUILTIN_FUNCTION_NAMES__ = Builtin_Functions__.public_instance_methods false

        # ~ custom functions

        class Build_fulfiller___ < Callback_::Actor::Dyadic

          Callback_::Event.selective_builder_sender_receiver self

          def initialize sym_a, path, & oes_p
            @custom_i_a = sym_a
            @functions_directory = path
            @_oes_p = oes_p
          end

          def execute

            set = ::Hash[ @custom_i_a.map { |i| [ i, true ] } ]

            @functions_pn = ::Pathname.new @functions_directory

            pn_a = @functions_pn.children false  # meh on ENOENT

            @method_name_to_file = {}

            pn_a.each do |cx_file_pn|
              _stem = cx_file_pn.sub_ext( EMPTY_S_ ).to_path
              meth_i = Callback_::Name.via_slug( _stem ).as_variegated_symbol
              set.delete meth_i  # OK if it didn't exist in set.
              @method_name_to_file[ meth_i ] = cx_file_pn.to_path
            end

            if set.length.zero?
              when_all_necessary_files_were_found
            else
              @missing_i_a = set.keys
              when_missing_files
            end
          end

          def when_missing_files

            @_oes_p.call :error, :missing_function_definitions do
              build_missing_function_definitions_event
            end
            UNABLE_
          end

          def build_missing_function_definitions_event

            _file_s_a = @missing_i_a.map do |i|
              "#{ Callback_::Name.via_variegated_symbol( i ).as_slug }#{
                }#{ Callback_::Autoloader::EXTNAME }"
            end

            _functions_dir = @functions_pn.to_path

            build_not_OK_event_with(
                :missing_function_definitions,
                :name_i_a, @missing_i_a,
                :file_s_a, _file_s_a,
                :functions_dir, _functions_dir ) do |y, o|

              a = o.name_i_a.map do |i|
                ick i
              end

              _path = if 1 == o.file_s_a.length
                "#{ o.functions_dir }/#{ o.file_s_a.first }"
              else
                "#{ o.functions_dir }/{#{ o.file_s_a * ', ' }}"
              end

              y << "#{ and_ a } #{ s :is } missing the expected #{
                }file#{ s } #{ pth _path }"
            end
          end

          def when_all_necessary_files_were_found

            resolve_class

            ok = true
            @custom_i_a.each do |i|
              @custom_i = i
              ok = load_file
              ok or break
            end
            ok and produce_fulfiller_instance
          end

          def load_file
            @path = @functions_pn.join( @method_name_to_file.fetch @custom_i ).to_path
            ok = resolve_tree_guess_via_path
            ok &&= load @path  # will load again, take complains about redefined consts
            ok and via_tree_guess_and_loaded_path_resolve_function
          end

          def resolve_tree_guess_via_path

            tree = Home_.lib_.system.filesystem.hack_guess_module_tree(
              @path,
              & @_oes_p )

            if tree
              @tree = tree
              ACHIEVED_
            else
              tree
            end
          end

          def via_tree_guess_and_loaded_path_resolve_function

            tree = @tree.dup_mutable
            tree.value_x = ::Object
            @func = nil

            tree.children_depth_first do |node|

              const_i_a = node.value_x

              x = const_i_a.reduce node.parent.value_x do |m, i|
                m.const_get i, false
              end

              if const_i_a.last.downcase == @custom_i
                @func = x
              else
                @func = Autoloader_.const_reduce [ @custom_i ], x do end
              end

              @func and break

              node.value_x = x
            end
            if ! @func  # search at toplevel
              @func = Autoloader_.const_reduce [ @custom_i ], ::Object do end
            end
            if @func
              when_func
            else
              self._WHEN_func_not_found
            end
          end

          Item__ = ::Struct.new :mod, :const_i_a

          def resolve_class
            @normal_path = @functions_pn.expand_path
            h = CLASS_CACHE__
            @class = h.fetch @normal_path do
              h[ @normal_path ] = allocate_new_class
            end
            nil
          end

          define_method :allocate_new_class, -> do
            num = -1
            fmt = 'Generated_Class_%02d___'
            -> do
              Class_Cache__.const_set ( fmt % ( num += 1 ) ),
                ::Class.new( Builtin_Functions__ )
            end
          end.call

          def when_func
            @class.__send__ :define_method, @custom_i, @func
            ACHIEVED_
          end

          def produce_fulfiller_instance
            h = FULFILLER_CACHE__  # if you mess with state that's on you
            h.fetch @normal_path do
              h[ @normal_path ] = @class.new
            end
          end
        end

        FULFILLER_CACHE__ = {}

        Class_Cache__ = ::Module.new
        CLASS_CACHE__ = {}

      end
    end
  # -
end
