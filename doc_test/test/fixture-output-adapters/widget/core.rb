module Skylab::DocTest

  module TestSupport::FixtureOutputAdapters::Widget

    # for [#025] - this is the first place we made a "choices" object.
    # abstract from here.

    class << self

      def choices_instance___
        @__choices_instance
      end
    end  # >>

    class Choices___

      def initialize
        NOTHING_  # (hi.)
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
        @___PL ||= Home_::OutputAdapter_::Paraphernalia_Loader.new Here_
      end

      def __template_loader
        @___TL ||= Home_::OutputAdapter_::Template_Loader.new Here_.dir_pathname.to_path
      end
    end

    @__choices_instance = Choices___.new

    Here_ = self
  end
end
