module Skylab::DocTest

  class RecursionMagnetics_::CounterpartDirectory_via_ArgumentPath_and_TestDirectory < Common_::Actor::Dyadic

    # exactly [#005]

    def initialize pa, pa_
      @argument_path = pa
      @test_directory = pa_
    end

    def execute

      @filesystem_directories ||= ::Dir
      @name_conventions ||= RecursionModels_::NameConventions.instance_

      ok = __check_the_lib_assumption
      ok &&= __step_downward_until_something_other_than_exactly_one_directory
      ok && __via_paths_from_glob
    end

    def __via_paths_from_glob

      paths = remove_instance_variable :@__paths_from_glob

      # here is an abstruse but flexible way to confirm the pattern we are
      # looking for in the "precursor directory" (not pictured, but it is
      # the directory the glob of which gave us the argument paths).
      #
      # group the paths by "stem" (multiple paths may share the same stem)
      # where the stem is the basename ("entry") of the path with its any
      # extension removed. once all paths are indexed in this way, this
      # index will have a certain structure IFF the precursor directory's
      # entries have the structure we expect as described in the document:
      #
      # for the precursor directory to match the pattern we are looking for,
      # this index will have only one stem, and that stem will have exactly
      # two entries under it (one file and one directory). the directory of
      # the two is then the target instance (the "counterpart directory").
      #
      # we might make this more lenient as needed. for example:
      #   - we could allow that there are multiple stems, but only one
      #     stem with more than one path under it.
      #   - we might want to allow that there is only a single file,
      #     and no directory (imagine a gem composed of one asset file.)
      # but we'll hold off on that until it reveals itself as a need.

      index = ::Hash.new { |h, k| h[k] = [] }
      paths.each do |path|
        basename = ::File.basename path
        extname = ::File.extname path
        if extname.length.zero?
          index[ basename ] << [ path, :dir ]
        else
          index[ basename[ 0 ... - extname.length ] ] << [ path, :file ]
        end
        # (add directories on one end and files on the other, so etc.)
      end

      if 1 < index.length  # if more than one stem
        self._COVER_ME_design_me_doesnt_look_like_gem
      else
        __when_one_stem index.values.fetch 0
      end
    end

    def __when_one_stem tuples  # assume at least one item long

      files = nil ; dirs = nil
      op = {
        file: -> path { ( files ||= [] ).push path },
        dir:  -> path { (  dirs ||= [] ).push path },
      }
      tuples.each do |path, type|
        op.fetch( type )[ path ]
      end

      if files
        if 1 == files.length
          if dirs
            1 == dirs.length || self._SANITY  # multiple dirs of same stem?
             dirs.fetch 0  # WHEW
          else
            self._ONE_FILE_NO_DIR_this_could_be_made_to_be_OK
          end
        else
          self._MUTIPLE_FILES_UNDER_ONE_STEM
        end
      else
        self._NO_FILES?  # ergo exactly one dir
      end
    end

    def __step_downward_until_something_other_than_exactly_one_directory

      dir = remove_instance_variable :@_lib_directory

      begin
        _glob = ::File.join dir, GLOB___
        paths = @filesystem_directories[ _glob ]
        cmp = 1 <=> paths.length

        if 1 == cmp  # when there are no entries:
          self._EMPTY_DIRECTORY
          break
        end

        if cmp.zero?  # when there is one entry:
          path = paths.fetch 0
          if ::File.extname( path ).length.zero?  # if looks like directory:
            dir = path  # (the same as concatting the entry to the path)
            redo
          end
          # when one entry that looks like file, procede to next step.
        end
        # when multiple entries, procede to next step.
        @__paths_from_glob = paths
        ok = ACHIEVED_
        break
      end while the_above
      ok
    end

    def __check_the_lib_assumption

      # we assume the test dir was found by being immediately under or
      # upwards from the argument dir. the "project dir" is tautologically
      # the dirname of the test dir (for now). from this we induce that the
      # the argument path must be within (or is) the project dir.

      proj_dir = ::File.dirname @test_directory
      len = proj_dir.length
      @argument_path[ 0, len ] == proj_dir || self._SANITY

      if len == @argument_path.length
        __check_the_lib_assumption_when_shorter_arg_path proj_dir
      else
        __check_the_lib_assumption_when_longer_arg_path len, proj_dir
      end
    end

    def __check_the_lib_assumption_when_longer_arg_path len, proj_dir

      # if the argument path is within the project dir, we can avoid an
      # extra filesystem hit by confirming the lib dir using the argument
      # path alone.

      scn = RecursionModels_::EntryScanner.via_path_ @argument_path
      scn.pos = len
      scn.expect_one_separator__

      lib = scn.scan_entry

      if LIB__ == lib
        @_lib_directory = ::File.join proj_dir, lib
        ACHIEVED_
      else
        self._COVER_ME_not_lib  # same as #here
      end
    end

    def __check_the_lib_assumption_when_shorter_arg_path proj_dir

      # .. but if the argument path is not within the project dir (we *think*
      # this is only possible in one case), then we have one more filesytem
      # hit to do

      dir = ::File.join proj_dir, LIB__
      if @filesystem_directories.exist? dir
        @_lib_directory = dir
        ACHIEVED_
      else
        self._COVER_ME_not_lib  # same as #here
      end
    end

    GLOB___ = '*'
    LIB__ = 'lib'
  end
end
