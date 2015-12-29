module Skylab::SubTree

  class CLI < Home_.lib_.brazen::CLI

    Brazen_ = Home_.lib_.brazen

    def back_kernel
      API.application_kernel_
    end

    module Actions

      class Files < CLI::Action_Adapter

        def init_properties

          # :+[#br-021]:#the-first-case-study, #note-st-1 #BUMF

          bbx = @bound.formal_properties.to_mutable_box_like_proxy

          fbx = bbx.dup

          prp = fbx.remove :input_stream

          bbx.replace :input_stream, prp.new_with_default { @resources.sin }

          prp = fbx.remove :output_stream

          bbx.replace :output_stream, prp.new_with_default { @resources.sout }

          @bound.change_formal_properties bbx

          @back_properties = bbx
          @front_properties = fbx

          # do not super. it's not what you want

          nil
        end
      end
    end

    class Expression_Agent

      def initialize ar
        @_action_reflection = ar
      end

      alias_method :calculate, :instance_exec

      # ~

      lib = Home_.lib_

      styling = lib.brazen::CLI_Support::Styling

      define_method :stylify_, styling::Stylify

      # ~ experimental model-specific customization

      def file_coverage_glyphset_identifier__
        :wide  # narrow | wide
      end

    private


      # ~ classifications for visual styling


      def code s
        "'#{ s }'"
      end

      def em s
        _strong s
      end

      def escape_path s
        # define_method :escape_path, lib.pretty_path_proc
        s
      end

      def hdr s
        _strong s
      end

      o = lib.basic::String.via_mixed.dup
      o.max_width = 60
      define_method :ick, o.to_proc
      alias_method :val, :ick

      def par_via_sym sym

        if @_action_reflection
          prp = @_action_reflection.front_properties[ sym ]
          if prp
            cat_sym = @_action_reflection.category_for prp
          end
        end

        _par prp, cat_sym, sym
      end

      def par prp

        if @_action_reflection
          cat_sym = @_action_reflection.category_for prp
        end

        _par prp, cat_sym, prp.name_symbol
      end

      def _par prp, cat_sym, sym

        if cat_sym

          _m = @_action_reflection.expression_strategy_for_category cat_sym
          send _m, prp

        else
          _ = if prp
            prp.name.as_slug
          else
            sym.id2name.gsub UNDERSCORE_, DASH_
          end
          "«#{ _ }»"  # :+#guillemets
        end
      end

      def render_property_as__option__ prp
          "'--#{ prp.name.as_slug }'"
      end

      def render_property_as__argument__ prp
        "<#{ prp.name.as_slug }>"
      end

      define_method :_strong, styling::Stylify.curry[ %i( green ) ]

      # ~ EN NLP

      lib.human::NLP::EN::Methods[ self, :private, [
        :and_,
        :both,
        :or_,
        :s,
      ]]
    end


    if false  # #change-this-at-step:10

    desc "see crude unit test coverage with a left-right-middle filetree diff"
    desc "  * test files with corresponding application files appear as green."
    desc "  * application files with no corresponding test files appear as red."

    argument_syntax '<path>'

    option_parser do |o|

      o.on '-l', '--list', "show a list of matched test files only." do
        @local_iambic.push :list_as, :list
      end

      o.on '-s', '--shallow', "show a shallow tree of matched test #{
          }files only." do
        @local_iambic.push :list_as, :test_tree_shallow
      end

      -> do

        h = { 'c' => :code, 't' => :test }.freeze

        o.on '-t', '--tree <c|t>', "show a debugging tree of the raw #{
            }[c]ode and/or [t]est only." do |tc|

          _x = h.fetch( tc, & :intern )
          @local_iambic.push :list_as, _x
        end
      end.call

      o.on '-v', '--verbose', 'verbose (debugging) output' do
        @local_iambic.push :verbose
      end
    end

    def cov path, _opts
      @local_iambic.push :path, path
      _const = Name_.via_variegated_symbol( :cov ).as_const
      _cls = CLI::Actions.const_get _const, false
      _act = _cls.new
      hot = _act.init_for_invocation_via_services get_services
      x = hot.invoke_via_iambic @local_iambic
      if false == x
        invite
        x = exitstatus_for_error
      end
      x
    end

    # --*--

    desc "see a left-middle-right filetree diff of rerun list vs. all tests."
    desc "  * tests that failed (that appeared in your rerun list) appear as red."
    desc "  * test that do not appear (that presumably passed *) appear as green."
    desc "  * note this does not take into account @wip tags etc"

    argument_syntax '<rerun-file>'

    desc " arguments: "

    desc "        <rerun-file>                a cucumber-like rerun.txt file"

    def rerun path
      param_h = { emitter: self, rerun: path }
      res = cli_invoke :rerun, param_h
      if false == ok
        res = invite_fuck_me :rerun
      end
      res
    end
    end
  end
end
# :+#tombstone: 'sub-tree' is explained
