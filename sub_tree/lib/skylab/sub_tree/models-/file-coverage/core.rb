module Skylab::SubTree

  class Models_::File_Coverage < API.action_class_  # :[#002].

    # (at writing this is the only :+[#br-013]:API.B - action at top.)

    class Silo_Daemon

      def initialize kr, unb

        @kernel = kr
        @unbound = unb
      end

      attr_reader :unbound
    end

    # ->

      Home_.lib_.brazen::Modelesque.entity self,

        :argument_arity, :one_or_more,

        :description, ( -> y do

          _prp = @_action_reflection.front_properties.fetch :test_file_suffix

          _s = _prp.default_proc.call.map do | s |
            ick s
          end.join ', '

          y << "the test file suffixes to use (default: #{ _s })"
        end ),

        :default_proc, -> do
          Home_.lib_.test_file_suffix_a
        end,

        :property, :test_file_suffix,

        # ~

        :required,

        :description, -> y do
          y << "the path to any file or folder in a project"
        end,

        :ad_hoc_normalizer, -> qkn, & oes_p do

          if qkn.is_known_known && qkn.value_x
            Home_.lib_.basic::Pathname.normalization.new_with( :absolute ).
              normalize_qualified_knownness( qkn, & oes_p )
          else
            qkn.to_knownness
          end
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

        _filesystem = Home_.lib_.system.filesystem

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
      # <-

    class Agnostic_Tree_Wrapper___

      def initialize tree
        @tree = tree
      end

      attr_reader :tree

      def name
        @nm ||= Callback_::Name.via_variegated_symbol :file_coverage_tree
      end

      def express_into_under y, expag

        File_Coverage_::Modalities::CLI::Agnostic_Text_Based_Expression.
          new( y, expag, @tree ).execute
      end
    end

    Autoloader_[ Actors_ = ::Module.new ]

    File_Coverage_ = self

    FILENAMES___ = Home_::Lib_::Test_dir_name_a[]

    Autoloader_[ Models_ = ::Module.new ]

    Models_::Entry = IDENTITY_

  end
end
