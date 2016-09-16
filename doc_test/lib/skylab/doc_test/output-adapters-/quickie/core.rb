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

      # --

      def some_original_test_line_stream
        ViewControllers_::Starter.new( self ).some_original_test_line_stream__
      end

      def begin_insert_into_empty_document doc
        Here_::DocumentWriteMagnetics_::Insert_into_Empty_Document.new doc, self
      end

      def test_document_parser
        Here_::Models::TestDocument::PARSER
      end

      # --

      def particular_paraphernalia_for_under para, x
        _sym = para.paraphernalia_category_symbol
        _cls = _paraphernalia_class_for _sym
        _cls.new para, self, x
      end

      def particular_paraphernalia_for para
        _sym = para.paraphernalia_category_symbol
        _cls = _paraphernalia_class_for _sym
        _cls.new para, self
      end

      def particular_paraphernalia_of_for sym, para
        _cls = _paraphernalia_class_for sym
        _cls.new para, self
      end

      def _paraphernalia_class_for sym
        @___PL ||= Home_::OutputAdapter_::Paraphernalia_Loader.new ViewControllers_
        @___PL.paraphernalia_class_for sym
      end

      def load_template_for file
        @___TL ||= Home_::OutputAdapter_::Template_Loader.new Template_dir___[]
        @___TL.build_template_via_file_path file
      end
    end

    Template_dir___ = Lazy_.call do
      ::File.join Here_.dir_pathname.to_path, 'templates-'
    end

    # ==

    module ViewControllers_
      Autoloader_[ self ]
    end

    Here_ = self
  end
end
