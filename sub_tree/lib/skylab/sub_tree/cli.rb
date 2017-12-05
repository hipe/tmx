module Skylab::SubTree

  class CLI < Home_.lib_.brazen::CLI

    Brazen_ = Home_.lib_.brazen

    def back_kernel
      API.application_kernel_
    end

    def build_expression_agent_for_this_invocation invo
      FullyCustomInterfaceExpressionAgent___.new invo
    end

    module Actions

      class Files < CLI::Action_Adapter

        def init_properties

          # :+[#br-021]:#the-first-case-study, [#br-041.3] #BUMF

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

    class FullyCustomInterfaceExpressionAgent___  #testpoint

      def initialize ar
        @_action_reflection = ar
      end

      alias_method :calculate, :instance_exec

      # ~

      lib = Home_.lib_

      styling = lib.zerk::CLI::Styling

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

      lib.human::NLP::EN::SimpleInflectionSession.edit_module self, :private, [
        :and_,
        :both,
        :or_,
        :s,
      ]

    end
  end
end
# :+#tombstone: 'sub-tree' is explained
