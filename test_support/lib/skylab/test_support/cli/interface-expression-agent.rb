module Skylab::TestSupport

  module CLI

    module InterfaceExpressionAgent ; class << self

      # fully custom [#ze-040] implementation that is stateless and memberless

      def instance__
        self
      end

      alias_method :calculate, :instance_exec

      # ~

      lib = Home_.lib_

      stylify = -> i_a, s do
        stylify = CLI_[]::Styling::Stylify
        stylify[ i_a, s ]
      end

      as = -> * i_a do
        -> s do
          stylify[ i_a, s ]
        end
      end

      # -- experimental utility-specific customization

      def file_coverage_glyphset_identifier__
        :wide  # narrow | wide
      end

      # -- ..

      def begin_handler_expresser
        Require_zerk_[]
        Zerk_::Expresser.via_expression_agent self
      end

      # --

      def pth path
        if Home_.lib_.system.path_looks_absolute path
          "(( [ts] xyzzy1 #{ path } ))"
        else
          path
        end
      end

      # -- reduce other structures to strings (& related)

      def render_list_commonly__ s_a
        s_a.map( & method( :ick ) ).join ', '
      end

      lib.human::NLP::EN::SimpleInflectionSession.edit_module self, :private,
        [ :and_, :or_, :plural_noun, :s ]

      # -- ways to style strings

      define_method :code, as[ :green ]

      pather = nil
      define_method :escape_path do |x|
        pather ||= lib.system.new_pather
        pather[ x ]
      end

      define_method :highlight, as[ :green ]  # [br]

      define_method :hdr, as[ :strong, :green ]  # [br]

      ick = -> x do
        o = lib.basic::String.via_mixed.dup
        o.max_width = 60
        ick = o.to_proc
        ick[ x ]
      end

      define_method :ick do |x|
        ick[ x ]
      end

      def lbl x
        x
      end

      def nm name
        "'#{ name.as_slug }'"
      end

      def par par
        "«#{ par.name.as_slug }»"
      end

      define_method :stylify_ do |i_a, s|
        stylify[ i_a, s ]
      end
    end ; end
  end
end
# #tombstone: text-to-speech blurb near expags
