module Skylab::DocTest

  module OutputAdapter_  # :[#004].

    # ==

    class Paraphernalia_Loader

      def initialize mod
        @module = mod
      end

      def paraphernalia_class_for sym
        Autoloader_.const_reduce [ sym ], @module
      end
    end

    class Template_Loader

      def initialize path
        @dir_path = path
      end

      def build_template_via_file_path file_path

        _full_path = ::File.expand_path file_path, @dir_path

        Home_::Models_::Template.via_full_path _full_path
      end
    end

    # ==

    # (when view controller, was [#005])

      Event_for_Wrote_ = Common_::Event.prototype_with :wrote,

        :is_known_to_be_dry, false,
        :bytes, nil,
        :line_count, nil,
        :ok, nil do | y, o |

          y << " done (#{ o.line_count } line#{ s o.line_count }, #{
            }#{ o.bytes }#{ ' (dry)' if o.is_known_to_be_dry } bytes)."
        end

  end
end
# +:#posterity: multiple early versions of stream via array, param lib
