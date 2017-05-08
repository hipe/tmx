module Skylab::TanMan

  module CLI
  # class CLI < Brazen_::CLI

    if false

    # ~ experimental front client customizations:

    expose_executables_with_prefix 'tmx-tan-man-'

    Branch_Adapter = Branch_Adapter

    class Action_Adapter < Action_Adapter

      def prepare_for_employment_under adapter
        if @bound.respond_to? :receive_stdin_
          o = adapter.resources
          @bound.receive_stdin_ o.sin
          @bound.receive_stdout_ o.sout
        end
        super
      end
    end

    module Actions

      class Status < Action_Adapter

        def init_properties  # :+[#br-042] #nascent-operation

          super

          mutable_back_properties.replace_by :path do | prp |

            prp.dup.set_default_proc do
              ::Dir.pwd
            end.set_is_not_required.freeze

          end
          @front_properties = @mutable_back_properties
          nil
        end
      end

      class Graph < Branch_Adapter
        module Actions
          class Use < Action_Adapter
            def init_properties  # :+[#br-042] #nascent-operation
              super
              mutable_back_properties.replace_by :digraph_path do | prp |
                prp.dup.append_ad_hoc_normalizer do | arg |
                  if arg.value_x and SLASH_BYTE___ != arg.value_x.getbyte( 0 )
                    arg = arg.new_with_value ::File.expand_path arg.value_x
                  end
                  arg
                end.freeze
              end
              nil
            end
          end
        end
      end
    end

    SLASH_BYTE___ = ::File::SEPARATOR.getbyte 0
    end

    # ~ could go away:

    class InterfaceExpressionAgent___  # #testpoint

      class << self
        def instance
          @__instance ||= new
        end
        private :new
      end  # >>

      if false
      def initialize action_reflection
        @kernel = action_reflection.application_kernel
      end
      end

      alias_method :calculate, :instance_exec

      def simple_inflection & p
        o = dup
        o.extend Home_.lib_.human::NLP::EN::SimpleInflectionSession::Methods
        o.calculate( & p )
      end

      # ~ new stuff to compat with whatever

      def ick_mixed x
        x.inspect
      end

      def ick_prim sym
        prim( sym ).inpsect
      end

      def ick_oper sym
        oper( sym ).inspect
      end

      def prim sym
        "-#{ _slug sym }"
      end

      def oper sym
        _slug sym
      end

      # ~ custom stuff

      def pth s
        if s.respond_to? :to_path
          s = s.to_path
        end
        if DIR_SEP___ == s.getbyte( 0 )
          # Zerk_lib_[]::CLI::InterfaceExpressionAgent::THE_LEGACY_CLASS.pretty_path s
          ::File.basename s
        else
          s
        end
      end
      DIR_SEP___ = ::File::SEPARATOR.getbyte 0

      def component_label s  # (replaces `lbl` #todo)
        s.ascii_only?  # hi.
        s.inspect
      end

      def symbol_as_identifier_ sym
        "'#{ _slug sym }'"
      end

      def code s
        kbd "'#{ s }'"
      end

      def mixed_primitive s
        s.inspect
      end

      def _slug sym
        sym.id2name.gsub UNDERSCORE_, DASH_
      end

      # ~

      if false  # bring back as needed

      def app_name_string
        @kernel.app_name_string
      end

      def invoke_notify
        Home_.lib_.old_path_tools.clear
      end

    private

      # follows [#ze-040]:#the-semantic-markup-guidelines

      green = 32 ; strong = 1

      def and_ a
        _NLP_agent.and_ a
      end

    public def hdr x
        stylize HEADER_STYLE__, "#{ x }:"
      end
      HEADER_STYLE__ = [ strong, green ].freeze

      def highlight string
        "** #{ string } **"
      end

      def ick x
        "\"#{ x }\""
      end

      def indefinite_noun lemma_s
        _NLP_agent.indefinite_noun lemma_s
      end

      def kbd s
        stylize KEYBOARD_STYLE__, s
      end
      KEYBOARD_STYLE__ = [ green ].freeze

      def lbl x  # render a business parameter name
        kbd x
      end

      def nm name
        "'#{ name.as_slug }'"
      end

      def or_ a
        _NLP_agent.or_ a
      end

      def par prop  # [#sl-036] - super hacked for now
        kbd "<#{ prop.name.as_slug.gsub '_', '-' }>"
      end

      def plural_noun * a
        _NLP_agent.plural_noun( * a )
      end

      def s * x_a
        _NLP_agent.s( * x_a )
      end

      def stylize style_d_a, string
        "\e[#{ style_d_a.map( & :to_s ).join( ';' ) }m#{ string }\e[0m"
      end

      def _NLP_agent
        @___NLP_agent ||= Zerk_lib_[]::Expresser::NLP_EN_ExpressionAgent.new
      end
      end  # if false
    end
  end
end
