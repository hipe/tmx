module Skylab::SearchAndReplace

    class Magnetics_::Replace_Function_via_String_and_Functions_Dir

      class Build_replace_expression__

        Attributes_actor_.call( self,
          :capture_identifier,
          :functions_dir,
          :method_call_chain,
        )

        def initialize & x_p
          @_oes_p = x_p
        end

        def execute

          @method_call_chain = @method_call_chain.map( & :intern )

          @custom_symbols = @method_call_chain - BUILTIN_FUNCTION_NAMES__

          _ok = ___resolve_fulfiller
          _ok && __via_fulfiller
        end

        def ___resolve_fulfiller

          if @custom_symbols.length.zero?

            fu = BUILTIN_FUNCTIONS__

          elsif @functions_dir

            fu = Build_fulfiller___.call(
              @custom_symbols,
              @functions_dir,
              & @_oes_p )

          else
            fu = ___when_no_functions_directory
          end

          __store_trueish :@fulfiller, fu
        end

        def ___when_no_functions_directory

          sym_a = @custom_symbols

          @_oes_p.call(

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

          ReplacementExpression___.define do |o|
            o.capture_identifier = @capture_identifier
            o.fulfiller = @fulfiller
            o.listener = @_oes_p
            o.method_call_chain = @method_call_chain
          end
        end

        define_method :__store_trueish, METHOD_DEFINITION_FOR_STORE_TRUEISH_

        class ReplacementExpression___ < Common_::SimpleModel

          # proof of concept class. currently not robust, secure, scalable

          def capture_identifier= ci
            @d = ci.to_i ; ci
          end

          attr_writer(
            :fulfiller,
            :listener,
            :method_call_chain,
          )

          def marshal_dump
            "{{ $#{ @d }#{ @method_call_chain.map do |s|
              ".#{ s }"
            end.join EMPTY_S_ } }}"
          end

          alias_method :as_text, :marshal_dump

          def call md
            s = md[ @d ]
            if s
              __call_normally s
            else
              __when_etc
              s
            end
          end

          def __when_etc
            d = @d
            @listener.call :error, :expression, :captured_subexpression_not_found do |y|
              y << "we are into uncharted territory here:"
              y << "what is the replacement value with there is nothing at"
              y << "that capture offset (capture offset: #{ d })?"
            end
          end

          def __call_normally s
            @method_call_chain.reduce s do |x, m|
              @fulfiller.__send__ m, x
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

        class Build_fulfiller___ < Common_::Dyadic

          Common_::Event.selective_builder_sender_receiver self

          def initialize sym_a, path, & oes_p
            @custom_symbols = sym_a
            @functions_directory = path
            @_oes_p = oes_p
          end

          def execute

            set = ::Hash[ @custom_symbols.map { |i| [ i, true ] } ]

            _entries = ::Dir.entries @functions_directory  # meh on ENOENT
            scn = Common_::Scanner.via_array _entries
            scn.gets_one == '.' || fail  # DOT_
            scn.gets_one == '..' || fail  # DOT_DOT_

            @method_name_to_file = {}

            until scn.no_unparsed_exists
              entry = scn.gets_one
              d = ::File.extname( entry ).length
              _stem = d.zero? ? entry : entry[ 0 ... -d ]
              meth_sym = Common_::Name.via_slug( _stem ).as_variegated_symbol
              set.delete meth_sym  # OK if it didn't exist in set.
              @method_name_to_file[ meth_sym ] = entry
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
              "#{ Common_::Name.via_variegated_symbol( i ).as_slug }#{
                }#{ Common_::Autoloader::EXTNAME }"
            end

            build_not_OK_event_with(
                :missing_function_definitions,
                :name_i_a, @missing_i_a,
                :file_s_a, _file_s_a,
                :functions_dir, @functions_directory,
            ) do |y, o|

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
            @custom_symbols.each do |i|
              @custom_symbol = i
              ok = load_file
              ok or break
            end
            ok and produce_fulfiller_instance
          end

          def load_file

            _tail = @method_name_to_file.fetch @custom_symbol
            @path = ::File.join @functions_directory, _tail

            ok = resolve_tree_guess_via_path
            ok &&= load @path  # will load again, take complains about redefined consts
            ok and via_tree_guess_and_loaded_path_resolve_function
          end

          def resolve_tree_guess_via_path

            _tree = Home_.lib_.system.filesystem.hack_guess_module_tree(
              @path,
              & @_oes_p )

            __store_trueish :@tree, _tree
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

              if const_i_a.last.downcase == @custom_symbol
                @func = x
              else
                @func = Autoloader_.const_reduce [ @custom_symbol ], x do end
              end

              @func and break

              node.value_x = x
            end
            if ! @func  # search at toplevel
              @func = Autoloader_.const_reduce [ @custom_symbol ], ::Object do end
            end
            if @func
              when_func
            else
              self._WHEN_func_not_found
            end
          end

          Item__ = ::Struct.new :mod, :const_i_a

          def resolve_class
            @normal_path = ::File.expand_path @functions_directory
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
            @class.__send__ :define_method, @custom_symbol, @func
            ACHIEVED_
          end

          def produce_fulfiller_instance
            h = FULFILLER_CACHE__  # if you mess with state that's on you
            h.fetch @normal_path do
              h[ @normal_path ] = @class.new
            end
          end

          define_method :__store_trueish, METHOD_DEFINITION_FOR_STORE_TRUEISH_
        end

        FULFILLER_CACHE__ = {}

        Class_Cache__ = ::Module.new
        CLASS_CACHE__ = {}

      end
    end
  # -
end
