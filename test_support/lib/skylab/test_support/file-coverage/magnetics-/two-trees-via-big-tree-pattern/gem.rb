module Skylab::TestSupport

  module FileCoverage

    module Magnetics_::TwoTrees_via_BigTreePattern::Gem ; class << self

      # assume argument path indicates the BHD and it "looks like" a gem.
      # we've got to consume the un-interesting "stalk" part of the tree
      # (of arbitrary length) til we get to the point of interest. raunchy!

      def call full, name_conventions

        o = full.asset.h_.fetch LIB_ENTRY_

        begin
          if 1 == o.length
            o = o.h_.fetch o.a_.fetch 0
            redo
          end
          2 == o.length || self._COVER_ME_not_look_like_gem
          break
        end while nil

        two_filenames = o.a_

        # one should have the extension and the other not.

        s_a = name_conventions.big_tree_filename_extensions
        1 == s_a.length || self._MEH
        ext = s_a.fetch 0

        r = - ext.length .. -1
        d = two_filenames.index do |s|
          ext == s[ r ]
        end
        d || self._COVER_ME_file_with_extension_not_found

        w_extension = two_filenames.fetch d
        wo_extension = two_filenames.fetch( d.zero? ? 1 : 0 )

        _yes = wo_extension == w_extension[ 0, wo_extension.length ]
        _yes || self._COVER_ME_the_one_did_not_look_like_the_other

        full.asset = o.h_.fetch wo_extension
        full
      end
      alias_method :[], :call
    end ; end
  end
end
