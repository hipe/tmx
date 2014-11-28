module Skylab::BeautySalon

  class Models_::Search_and_Replace

    class Actors_::Build_replace_function

      class Build_replace_expression__

        Callback_::Actor.call self, :properties,

          :capture_identifier,
          :method_call_chain,
          :work_dir,
          :as_normal_value,
          :on_event_selectively

        def execute
          @method_call_chain = @method_call_chain.map( & :intern )
          @custom_i_a = @method_call_chain - BUILTIN_FUNCTION_NAMES__
          @fulfiller = if @custom_i_a.length.zero?
            BUILTIN_FUNCTIONS__
          else
            Produce_fulfiller__[ @custom_i_a, @work_dir, @on_event_selectively ]
          end
          @fulfiller and via_fulfiller
        end

        def via_fulfiller
          @as_normal_value[
            Replace_Expression__.new @method_call_chain,
              @capture_identifier, @fulfiller ]
        end

        class Replace_Expression__

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

        class Produce_fulfiller__

          class << self
            def [] * a
              new( a ).execute
            end
          end

          BS_._lib.event_lib.selective_builder_sender_receiver self

          def initialize a
            @custom_i_a, @work_dir, @oes = a
          end

          def execute
            set = ::Hash[ @custom_i_a.map { |i| [ i, true ] } ]

            @functions_pn = ::Pathname.new "#{ @work_dir }/functions"

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
            @oes.call :error do
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
            @tree = Self_::Hack_guess_module_tree__[ @path, @oes ]
            @tree ? ACHIEVED_ : UNABLE_
          end

          def via_tree_guess_and_loaded_path_resolve_function
            @tree.value = ::Object
            @func = nil
            @tree.traverse do |node|
              node.value = node.parent.value.const_get( node.name_i, false )
              @func = Autoloader_.const_reduce [ @custom_i ], node.value do end
              @func and break
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
  end
end
