module Skylab::TestSupport

  module DocTest

    class Idioms_::Template

      # see sibling filesystem idiom for desc

      def initialize dir, cache

        @cache = cache
        @dir = dir

      end

      def template sym
        @cache.cached :templates, sym do
          template_via_sym sym
        end
      end

      def templates * i_a
        templates_via_list i_a
      end

      def templates_via_list i_a
        h = @cache.touch_head_hash :templates
        i_a.map do | i |
          h.fetch i do
            h[ i ] = template_via_sym i
          end
        end
      end

      def template_via_sym sym
        Template__.via_path path_via_sym sym
      end

      def path_via_sym sym
        ::File.join @dir, "#{ sym }#{ EXT__ }"
      end

      EXT__ = '.tmpl'.freeze

      Template__ = TestSupport_._lib.string_lib.template

    end
  end
end
