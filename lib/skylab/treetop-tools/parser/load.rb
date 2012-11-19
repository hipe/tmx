module Skylab::TreetopTools
  class Parser::Load < DSL::Client::Minimal
    # #pattern [#sl-109] class as namespace
  end

  class Parser::Load::DSL < DSL::Joystick
    # Define the DSL that will be used to load grammars.

    def self.parameter_definition_class        # [#sl-119] one day DSL
      Parameter # has extra nonsense for dirs [#hl-009] HL::P strain?
    end

    def self.pathname_class                    # [#sl-119] one day DSL
      Pathname # sub-product-wide we use our local version
    end

    param :enhance_parser_with, dsl: :list

    param :force_overwrite, boolean: true

    param :generated_grammar_dir, dsl: :value, required: true,
      pathname: :dir, exist: :must

    param :root_for_relative_paths, dsl: :value, pathname: :dir

    param :treetop_grammar, dsl: :list, required: true,
      pathname: true, exist: :must

  end


  class Parser::Load # re-open!

    include Headless::Parameter::Bound::InstanceMethods # bound_parameters

    attr_reader(* DSL.parameters.each.map(&:name)) # for after
                                                   # call_body_and_absorb
    def invoke
      result = false
      begin
        call_body_and_absorb! or break

        # we want to hold on to the string representation of the path exactly
        # as the user provided it before we normalize it
        @grammars = treetop_grammar.each_with_index.map do |pn, i|
          Grammar::Reflection.new(pn.to_s, ->{ treetop_grammar[i] },
                                  -> { generated_grammar_dir })
        end
        normalize_and_validate_paths_to :root_for_relative_paths or break
        load_or_generate_grammar_files or break
        a = grammars.last.nested_const_names or break
        a[a.length - 1] = "#{ a.last }Parser"
        klass = a.reduce(::Object) { |m, c| m.const_get c, false }
        a = enhance_parser_with and a.each { |mod| klass = subclass klass, mod }
        result = klass
      end while false
      result
    end

  protected

    def compiler
      @compiler ||= ::Treetop::Compiler::GrammarCompiler.new
    end

    def file_utils                # could benefit from [#tm-042] f.u as svc
      require 'fileutils'
      ::FileUtils
    end

    attr_reader :grammars

    STACK_RE = %r{\A(?<file>[^:]+):(?<line>\d+)(?::in `(?<method>[^']+)')?\z/}
    def load_or_generate_grammar_files
      summarize grammars
      grammars.each do |g|
        defined?(::Treetop) or Headless::FUN.require_quietly[ 'treetop' ]
        if force_overwrite or ! g.outpathname.exist?
          recompile(g) or return
        end
        begin
          require g.outpathname.bare
        rescue ::NameError => e
          _context = (md = STACK_RE.match e.backtrace[0]) ?
            "in #{ File.basename(md[:file]) }:#{ md[:line] }" :
            "(#{ e.backtrace[0] })"
          raise RuntimeError.new( [e.message, _context].join(' ') )
        end
      end
      true
    end

    def mkdir_safe g
      # don't make any new directories deeper than the amt of dirs in grammar
      parent = g.outpathname.dirname
      g.name.scan(%r</>).size.times{ parent = parent.dirname }
      if parent.directory?
        file_utils.mkdir_p(g.outpathname.dirname.to_s, verbose: true)
        true
      else
        error("directory must exist: #{parent.pretty}")
        false
      end
    end

    def normalize_and_validate_paths_to param_name
      errors_count_before = errors_count
      root_f = ->(bp) do
        root = bound_parameters[param_name]
        ! root.value and return error("#{root.name} must be set in " <<
          "order to support a relative path like #{bp.label}!")
        ! root.value.absolute? and return error("#{root.name} must " <<
          "be an absolute path in order to expand paths like #{bp.label}")
        (root_f = ->(_) { root }).call(nil)
      end
      pathname_params = bound_parameters.where do |bp|
        bp.known?(:pathname) and bp[:pathname]
      end.to_a
      pathname_params.each do |bp|
        bp.value or next # if path value wasn't specified, leave brittany alone
        if ! bp.value.absolute? # expand *all* relative paths
          bp.value = root_f[bp].value.join(bp.value) # sexy and evil
        end
        if bp.value.exist?
          if bp.parameter.dir? and ! bp.value.directory?
            error("#{ bp.label } is not a directory: #{ p.value.pretty }")
          end
        elsif bp.parameter.known?(:exist) and :must == bp.parameter.exist
          error("#{ bp.label } not found: #{ bp.value.pretty }")
        end
      end
      errors_count == errors_count_before
    end

    def recompile g
      g.outpathname.dirname.directory? or mkdir_safe(g) or return
      begin
        compiler.compile(g.inpath, g.outpath)
        true
      rescue ::RuntimeError => e
        raise RuntimeError.new("when compiling #{g.name}:\n#{e.message}")
      end
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

    def summarize grammars
      exists = []; creates = []
      grammars.each { |g| (g.outpathname.exist? ? exists : creates).push g }
      exists.empty? or emit(:info, "#{force_overwrite ? 'overwrit' : 'us'
        }ing: #{exists.map(&:outpath).join(', ')}")
      creates.empty? or
        emit(:info, "creating: #{creates.map(&:outpath).join(', ')}")
      grammars.empty? and emit(:info, "none.")
      true
    end
  end
end
