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

      def best_root_contextesque_node_for_test_document__ ersatz_test_document

        # new in this commit (#here) we want the choices to decide what is
        # the appropriate document branch node to use as the root-level
        # branch node for the purpose of all document edits (near [#035]).
        # at present it's a rough sketch, not smart enough to work for all
        # test documents, just most of ours (probably).

        # if you can find `[ module [ module [..]]] describe`, use that.
        # otherwise use the root document

        branch = ersatz_test_document
        begin
          branch_ = branch.first_via_category_symbol :module
          if branch_
            branch = branch_
            redo
          end
          break
        end while above

        desc = branch.first_via_category_symbol :describe
        if desc
          desc
        else
          ersatz_test_document
        end
      end

      def some_original_test_line_stream
        ViewControllers_::Starter.via_choices( self ).some_original_test_line_stream__
      end

      def begin_insert_into_empty_document doc
        Here_::DocumentWriteMagnetics_::Insert_into_Empty_Document.new doc, self
      end

      def test_document_parser
        Here_::Models::TestDocument::PARSER
      end

      # --

      def particular_paraphernalia_of_for_under sym, para, x
        _cls = _paraphernalia_class_for sym
        _cls.via_three_ para, x, self
      end

      def particular_paraphernalia_for_under para, x
        _sym = para.paraphernalia_category_symbol
        _cls = _paraphernalia_class_for _sym
        _cls.via_three_ para, x, self
      end

      def particular_paraphernalia_for para
        _sym = para.paraphernalia_category_symbol
        _cls = _paraphernalia_class_for _sym
        _cls.via_two_ para, self
      end

      def particular_paraphernalia_of_for sym, para
        _cls = _paraphernalia_class_for sym
        _cls.via_two_ para, self
      end

      def _paraphernalia_class_for sym
        @___PL ||= Home_::OutputAdapter_::Paraphernalia_Loader.new ViewControllers_
        @___PL.paraphernalia_class_for sym
      end

      def load_template_for file
        @___TL ||= Home_::OutputAdapter_::Template_Loader.new Template_dir___[]
        @___TL.build_template_via_file_path file
      end

      def test_directory_entry

        # use "name conventions" to get this instead, if you've got it.
        # this was exposed solely to support #spot-7.

        DEFAULT_TEST_DIRECTORY_ENTRY_
      end
    end

    # ==

    Template_dir___ = Lazy_.call do
      ::File.join Here_.dir_pathname.to_path, 'templates-'
    end

    # ==

    module DocumentWriteMagnetics_
      Autoloader_[ self ]
    end

    module ViewControllers_
      Autoloader_[ self ]
    end

    Here_ = self
  end
end
# #history - #here
