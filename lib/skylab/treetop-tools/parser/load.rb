module Skylab::TreetopTools

  Parser::Load = ::Class.new DSL::Client::Minimal

  class Parser::Load::Shell__ < DSL::Shell

    # Define the DSL that will be used to load grammars.

    def self.formal_parameter_class            # [#sl-119] one day DSL
      Parameter # has extra nonsense for dirs [#hl-009] HL::P strain?
    end

    param :enhance_parser_with, dsl: :list

    param :force_overwrite, boolean: true

    param :generated_grammar_dir, dsl: :value, required: true,
      pathname: :dir, exist: :must

    param :root_for_relative_paths, dsl: :value, pathname: :dir

    param :treetop_grammar, dsl: :list, required: true,
      pathname: true, exist: :must

  end

  class Parser::Load

    include LIB_.parameter::Bound::InstanceMethods  # bound_parameters

    attr_reader( * Shell__.parameters.get_names )


                                  # for after call_body_and_absorb

    Callback_::Event.selective_builder_sender_receiver self

    def invoke
      ok = call_body_and_absorb!
      ok && init_ivars
      ok &&= normalize_and_validate_paths
      ok && start_loads
      ok &&= load_or_generate_grammar_files
      ok && produce_parser_class
    end

  private

    def init_ivars
      @treetop_grammar_pn_a_before_absolution = @treetop_grammar.dup ; nil
    end

    def normalize_and_validate_paths
      _relpath_root = bound_parameters[ :root_for_relative_paths ]
      Parser::Load::Normalize_and_validate_paths__[ _relpath_root, self ]
    end

    def start_loads
      @grammar_a = @treetop_grammar.length.times.map do |d|
        start_load_grammar d
      end
    end

    def start_load_grammar d
      g = Load_Grammar__.new
      g.in_pn = @treetop_grammar.fetch d
      tail_pn = @treetop_grammar_pn_a_before_absolution.fetch d
      g.tail_path = tail_pn.to_path
      _base_pn = if tail_pn.absolute?
        tail_pn
      else
        @generated_grammar_dir.join tail_pn
      end
      g.out_path = "#{ _base_pn }#{ Autoloader_::EXTNAME }"  # [..]/g1.treetop.rb
      g.module_name_i_a = TreetopTools_::Hack_peek_module_name__[ g.in_pn.to_path ]
      g
    end

    class Load_Grammar__
      attr_accessor :in_pn, :module_name_i_a, :tail_path
      def out_path= s
        @out_pn = ( s ? ::Pathname.new( s ) : s ) ; s
      end
      attr_reader :out_pn
    end

    def produce_parser_class
      g = @grammar_a.last
      i_a = g.module_name_i_a.dup
      i_a[ -1 ] = :"#{ i_a.last }Parser"
      cls = Callback_::Module_path_value_via_parts[ i_a ]
      a = enhance_parser_with
      if a
        cls = enhance_parser_via_a cls, a
      end
      cls
    end

    def enhance_parser_via_a cls, a
      a.each do |mod|
        cls = subclass cls, mod
      end
      cls
    end

    def compiler
      @compiler ||= ::Treetop::Compiler::GrammarCompiler.new
    end

    def load_or_generate_grammar_files
      via_grammars_summarize
      if @grammar_a.length.nonzero?
        LIB_.treetop
      end
      ok = PROCEDE_
      @grammar_a.each do |g|
        ok = load_or_generate_grammar_file_for_grammar g
        ok or break
      end
      ok
    end

    def via_grammars_summarize
      grammar_a = @grammar_a
      exist_g_a = [] ; create_g_a = []
      grammar_a.each do |g|
        ( if g.out_pn.exist?
          exist_g_a
        else
          create_g_a
        end ).push g
      end
      if exist_g_a.length.nonzero?
        send_overwriting_event exist_g_a
      end
      if create_g_a.length.nonzero?
        send_creating_event create_g_a
      end
      if grammar_a.length.zero?
        send_none_event
      end
      PROCEDE_
    end

    def load_or_generate_grammar_file_for_grammar g
      ok = recompile_if_necessary g
      ok and require_the_file g
    end

    def recompile_if_necessary g
      if @force_overwrite or ! g.out_pn.exist?
        recompile g
      else
        PROCEDE_
      end
    end

    def require_the_file g
      _path = g.out_pn.sub_ext( EMPTY_S_ ).to_path
      require _path
      PROCEDE_
    rescue ::NameError => e
      raise say_name_error_in_grammar_file e
    end

    def say_name_error_in_grammar_file e
      md = STACK_RX_.match e.backtrace[ 0 ]
      _ctx_s = if md
        "in #{ ::File.basename( md[ :file ] ) }:#{ md[ :line ] }"
      else
        "(#{ e.backgrace[ 0 ] })"
      end
      "#{ e.message } #{ _ctx_s }"
    end

    STACK_RX_ = %r{\A(?<file>[^:]+):(?<line>\d+)(?::in `(?<method>[^']+)')?\z/}

    def mkdir_safe g
      # don't make any new directories deeper than the amt of dirs in grammar
      parent = g.out_pn.dirname
      _num_slashes = g.tail_path.scan( %r(/) ).length
      _num_slashes.times do
        parent = parent.dirname
      end
      if parent.directory?
        file_utils.mkdir_p g.out_pn.dirname.to_s, verbose: true
        PROCEDE_
      else
        send_directory_must_exist_error parent
        UNABLE_
      end
    end

    def send_directory_must_exist_error pn
      _ev = build_error_event :directory_must_exist, :pathname, pn
      send_error_event _ev
    end


    def normalize_and_validate_paths_to param_i
      @error_count ||= 0
      error_count_before = @error_count
      resolve_pathname_actual_a

      @pathname_actual_a.each do |bp|

        bp.value or next  # it path wasn't specified, leave brittany alone

        if ! bp.value.absolute?  # expand  relative paths
          root_pn = produce_root_pn_given_pathname_bp bp, param_i
          root_pn or break
          bp.value = root_pn.join bp.value
        end

        if bp.value.exist?
          if bp.parameter.dir? and ! bp.value.directory?
            send_not_directory_error bp
          end

        elsif bp.parameter.known? :exist and :must == bp.parameter.exist
          send_not_found_error bp
        end
      end
      @error_count == error_count_before
    end

    def resolve_pathname_actual_a
      @pathname_actual_a = bound_parameters.where do |bp|
        if bp.known? :pathname
          bp[ :pathname ]
        end
      end.to_a ; nil
    end

    def produce_root_pn_given_pathname_bp bp, param_i
      @did_resolve_root_pn ||= resolve_root_pn( bp, param_i )
      @root_pn
    end

    def resolve_root_pn bp, param_i
      root_bp = bound_parameters[ param_i ]
      x = root_bp.value
      if x
        if x.absolute?
          @root_pn = x
        else
          send_not_abspath_error bp, root_bp
          @root_pn = false
        end
      else
        send_no_anchor_error bp, root_bp
        @root_pn = false
      end
      true
    end

    def send_no_anchor_error prop, prop_
      _ev = build_not_OK_event_with :no_anchor_path do |y, o|
        y << "#{ prop_.normalized_parameter_name } must be set #{
          }in order to support a relative path like #{ prop.label }!"
      end
      send_error_event _ev
    end

    def send_not_abspath_error prop, ro
      _ev = build_not_OK_event_with :not_absolute_path, :prop, prop do |y, o|
        y << "#{ prop_.normalized_parameter_name } must be an absolute #{
          }path in order to expand paths like #{ prop.label }"
      end
      send_error_event _ev
    end

    def send_not_directory_error prop
      _ev = build_not_OK_event_with :not_a_directory, :prop, prop do |y, o|
        y << "#{ o.prop.label } is not a directory: #{ pth prop.value }"
      end
      send_error_event _ev
    end

    def send_not_found_error prop
      _ev = build_not_OK_event_with :not_found, :prop, prop do |y, o|
        y << "#{ prop.label } not found: #{ pth prop.value }"
      end
      send_error_event _ev
    end

    def recompile g
      ok = maybe_mkdir g
      ok and via_compiler_compile g
    end

    def maybe_mkdir g
      ok = PROCEDE_
      if ! g.out_pn.dirname.directory?
        ok = mkdir_safe g
      end
      ok
    end

    def via_compiler_compile g
      compiler.compile g.in_pn, g.out_pn
      PROCEDE_
    rescue ::RuntimeError => e  # #open [#005]
      raise ::RuntimeError, say_wrapped_runtime_error_message( e, g )
    end

    def say_wrapped_runtime_error_message e, g
      "when compiling #{ g.normalized_grammar_name }:\n#{
        }#{ e.message }"
    end

    def subclass cls, mod
      newcls = ::Class.new(cls)
      cls_modname, cls_basename =
        cls.to_s.match(/\A(?:(.*[^:])::)?([^:]+)\Z/).captures
      newcls.class_eval do
        include mod
        mod.override.each { |meth| alias_method meth, "my_#{meth}" }
      end
      parent_mod = (cls_modname.nil?) ? ::Object :
        cls_modname.split('::').inject(::Object){ |m,n| m.const_get(n) }
      nonum, num = cls_basename.match(/\A(.*[^0-9])([0-9]+)?\Z/).captures
      i = num ? (num.to_i + 1) : 2
      i += 1 while(parent_mod.const_defined?(usename = "#{nonum}#{i}"))
      newconst = parent_mod.const_set(usename, newcls)
      newconst
    end

    def send_overwriting_event exist_g_a
      i = @force_overwrite ? :overwriting : :using
      _ev = build_neutral_event_with i, :exist_g_a, exist_g_a do |y, o|
        _s_a = o.exist_g_a.map do |g|
          pth g.out_pn
        end
        y << "#{ i }: #{ _s_a * ', ' }"
      end
      send_info_event _ev
    end

    def send_creating_event create_g_a
      _ev = build_neutral_event_with :creating, :create_g_a, create_g_a do |y, o|
        _s_a = o.create_g_a.map do |g|
          pth g.out_pn
        end
        y << "creating: #{ _s_a * ', ' }"
      end
      send_info_event _ev
    end

    def send_none_event
      _ev = build_neutral_event_with :none do |y, o|
        y << "none."
      end
      send_info_event _ev
    end

  public
    def receive_error_event ev
      send_error_event ev
    end
  private

    def send_info_event ev
      call_digraph_listeners :info, ev
    end

    def send_error_event ev
      @error_count += 1
      call_digraph_listeners :error, ev
    end

    def file_utils
      LIB_.file_utils
    end



    EMPTY_S_ = ''.freeze
  end
end
