module Skylab::DocTest

  module OutputAdapters_::Quickie

    class << self
      def begin_choices
        Choices___.__begin
      end
    end  # >>

    class Choices___

      class << self
        alias_method :__begin, :new
        undef_method :new
      end  # >>

      def initialize
        NOTHING_  # (hi.)
      end

      def init_default_choices
        NIL_
      end

      def particular_paraphernalia_for para

        _cls = __paraphernalia_loader.paraphernalia_class_for(
          para.paraphernalia_category_symbol )

        _cls.new para, self
      end

      def load_template_for file
        __template_loader.build_template_via_file_path file
      end

      def __paraphernalia_loader
        @___PL ||= Home_::OutputAdapter_::Paraphernalia_Loader.new ViewControllers_
      end

      def __template_loader
        @___TL ||= Home_::OutputAdapter_::Template_Loader.new Template_dir___[]
      end
    end

    Template_dir___ = Common_::Lazy.call do
      ::File.join Here_.dir_pathname.to_path, 'templates-'
    end

    # ==

    module ViewControllers_
      Autoloader_[ self ]
    end

    Here_ = self
  end
end
