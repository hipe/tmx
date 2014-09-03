module Skylab::TreetopTools

  class Parser::Load < DSL::Client::Minimal
    # #pattern [#sl-109] class as namespace
  end

  class Parser::Load::DSL < DSL::Joystick
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

  class Parser::Load # re-open!

    include Lib_::Parameter[]::Bound::InstanceMethods  # bound_parameters

    attr_reader(* DSL.parameters.each.map(& :normalized_parameter_name ) )
                                  # for after call_body_and_absorb
    def invoke
      result = false
      begin
        call_body_and_absorb! or break

        # we want to hold on to the string representation of the path exactly
        # as the user provided it before we normalize it
        @grammar_a = treetop_grammar.each_with_index.map do |pn, i|
          Lib_::Const_pryer[].new(
            :outfile_stem, pn.to_s,
            :inpath_p, -> { treetop_grammar[ i ] },
            :outdir_p, -> { generated_grammar_dir } )
        end
        normalize_and_validate_paths_to :root_for_relative_paths or break
        load_or_generate_grammar_files or break
        a = @grammar_a.last.get_nested_const_names or break
        a[a.length - 1] = "#{ a.last }Parser"
        klass = a.reduce(::Object) { |m, c| m.const_get c, false }
        a = enhance_parser_with and a.each { |mod| klass = subclass klass, mod }
        result = klass
      end while false
      result
    end

  private

    def compiler
      @compiler ||= ::Treetop::Compiler::GrammarCompiler.new
    end

    def file_utils                # could benefit from [#tm-042] f.u as svc
      require 'fileutils'
      ::FileUtils
    end

    def load_or_generate_grammar_files
      summarize @grammar_a
      @grammar_a.each do |g|
        defined? ::Treetop or Autoloader_.require_quietly 'treetop'
        if force_overwrite or ! g.outpathname.exist?
          recompile(g) or return
        end
        begin
          require g.outpathname.sub_ext('').to_s
        rescue ::NameError => e
          _context = (md = STACK_RX_.match e.backtrace[0]) ?
            "in #{ File.basename(md[:file]) }:#{ md[:line] }" :
            "(#{ e.backtrace[0] })"
          raise RuntimeError.new( [e.message, _context].join(' ') )
        end
      end
      true
    end

    STACK_RX_ = %r{\A(?<file>[^:]+):(?<line>\d+)(?::in `(?<method>[^']+)')?\z/}

    def mkdir_safe g
      # don't make any new directories deeper than the amt of dirs in grammar
      parent = g.outpathname.dirname
      g.path.scan(%r</>).size.times{ parent = parent.dirname }
      if parent.directory?
        file_utils.mkdir_p(g.outpathname.dirname.to_s, verbose: true)
        true
      else
        error "directory must exist: #{ escape_path parent }"
        false
      end
    end

    def normalize_and_validate_paths_to param_name

      error_count_before = error_count

      root = -> bp do
        rot = bound_parameters[ param_name ]
        if ! rot.value
          error "#{ rot.normalized_parameter_name } must be set #{
            }in order to support a relative path like #{ bp.label }!"
          nil
        elsif ! rot.value.absolute?
          error "#{ rot.normalized_parameter_name } must be an absolute path #{
            }in order to expand paths like #{ bp.label }"
          nil
        else
          res = rot.value
          root = -> _ { res }
          res
        end
      end

      pathname_param_a = bound_parameters.where do |ap| # `ap`= actual parameter
        ap.known? :pathname and ap[:pathname]
      end.to_a

      pathname_param_a.each do |ap|
        if ap.value
          # it path wasn't specified, leave brittany alone
          if ! ap.value.absolute?  # expand *all* relative paths
            rot = root[ ap ] or break
            ap.value = rot.join ap.value
          end
          if ap.value.exist?
            if ap.parameter.dir? and ! ap.value.directory?
              error "#{ ap.label } is not a directory: #{ escape_path ap.value}"
            end
          elsif ap.parameter.known? :exist and :must == ap.parameter.exist
            error "#{ ap.label } not found: #{ escape_path ap.value }"
          end
        end
      end
      error_count == error_count_before
    end

    def recompile g
      ok = true
      if ! g.outpathname.dirname.directory?
        if ! mkdir_safe g
          ok = false
        end
      end
      if ok
        begin
          compiler.compile g.inpath, g.outpath
        rescue ::RuntimeError => e
          raise ::RuntimeError, "when compiling #{ g.normalized_grammar_name }#{
            }:\n#{ e.message }"
        end
      end
      ok
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

    def summarize grammar_a
      exists = []; creates = []
      grammar_a.each { |g| (g.outpathname.exist? ? exists : creates).push g }
      exists.empty? or call_digraph_listeners(:info, "#{force_overwrite ? 'overwrit' : 'us'
        }ing: #{exists.map(&:outpath).join(', ')}")
      creates.empty? or
        call_digraph_listeners(:info, "creating: #{creates.map(&:outpath).join(', ')}")
      grammar_a.length.zero? and call_digraph_listeners :info, "none."
      true
    end
  end
end
