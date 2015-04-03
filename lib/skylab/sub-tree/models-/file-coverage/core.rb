module Skylab::SubTree

  class Models_::File_Coverage

    Actions = ::Module.new

    class << self
      def is_silo
        true
      end
    end  # >>

    class Silo_Daemon
      def initialize kr, mc
        @kernel = kr
        @model_class = mc
      end
      attr_reader :model_class
    end

    class Actions::File_Coverage < API.action_class_

      @is_promoted = true

      SubTree_.lib_.brazen.model.entity self,

        :argument_arity, :one_or_more,
        :description, -> y do
          y << "the test file suffixes to use (default: etc)"  # #todo
        end,
        :default_proc, -> do
          SubTree_.lib_.test_file_suffix_a
        end,
        :property, :test_file_suffix,

        :required,
        :description, -> y do
          y << "the path to any file or folder in a project"
        end,
        :property, :path

      def produce_result

        @be_verbose = false  # placeholder
        @max_num_dirs = -1  # meh
        @path = @argument_box.h_.fetch :path

        ok = __find_the_test_directory
        ok &&= __classify_the_path
        ok &&= __resolve_name_conventions
        ok &&= __via_path_classification_resolve_the_tree
        ok && @wrapped_tree
      end

      def __find_the_test_directory  # assume @max_num_dirs and @path

        @test_dir = File_Coverage_::Actors_::Find_the_test_directory.with(

          :filenames, FILENAMES___,
          :start_path, @path,
          :be_verbose, @be_verbose,
          :max_num_dirs_to_look, @max_num_dirs,
          & handle_event_selectively )

        @test_dir && ACHIEVED_
      end

      def __classify_the_path

        cx = File_Coverage_::Actors_::Classify_the_path[
          @test_dir, @path, & handle_event_selectively ]

        cx and begin
          @classifications = cx
          ACHIEVED_
        end
      end

      def __resolve_name_conventions

        _suffix_a = @argument_box.h_.fetch :test_file_suffix  # assume ary

        _pattern_s_a = _suffix_a.map do | s |
          "*#{ s }"
        end

        @name_conventions = File_Coverage_::Models_::Name_Conventions.
          new _pattern_s_a

        ACHIEVED_
      end

      def __via_path_classification_resolve_the_tree

        _filesystem = SubTree_.lib_.system.filesystem

        tree = File_Coverage_::Actors_::Build_compound_tree[

          @classifications,
          @path,
          @test_dir,
          @name_conventions,
          _filesystem,
          & handle_event_selectively ]

        tree and begin
          @wrapped_tree = Agnostic_Tree_Wrapper___.new tree
          ACHIEVED_
        end
      end
    end

    class Agnostic_Tree_Wrapper___
      def initialize tree
        @tree = tree
      end
      attr_reader :tree
    end

    Autoloader_[ Actors_ = ::Module.new ]

    File_Coverage_ = self

    FILENAMES___ = SubTree_::Lib_::Test_dir_name_a[]

    Autoloader_[ Models_ = ::Module.new ]

    Models_::Entry = IDENTITY_

  end
end
