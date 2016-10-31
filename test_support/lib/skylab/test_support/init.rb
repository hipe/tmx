module Skylab

  module TestSupport

    module Init  # this node may be loaded before even the core file for
      # this subsystem is loaded so that these constants can be used to
      # generate test coverage, where that coverage may even be for
      # arbitrary nodes in this subsystem (other than this one). so don't
      # pull in any other files from this one, and don't expect to have
      # any accesss to any subsystem facilities here.

      _MEMBERS = []

      define_singleton_method :o, -> i, & p do

        _MEMBERS.push i

        p_ = -> do
          x = p[]
          p_ = -> { x }
          x
        end

        define_singleton_method i do
          p_[]
        end
      end

      o :test_file_name_pattern do

        "*#{ spec_rb }".freeze
      end

      _EXTNAME = '.rb'.freeze

      o :spec_rb do

        "#{ test_file_basename_suffix_stem }#{ _EXTNAME }".freeze
      end

      o :test_file_basename_suffix_stem  do

        '_spec'.freeze
      end

      o :test_support_filenames do

        [ "#{ test_support_filestem }#{ _EXTNAME }".freeze ].freeze
      end

      o :test_support_filestem do

        'test-support'.freeze
      end

      o :test_directory_entry_name do

        'test'.freeze
      end

      _MEMBERS.freeze

      define_singleton_method :members, -> do
        _MEMBERS
      end
    end
  end
end
