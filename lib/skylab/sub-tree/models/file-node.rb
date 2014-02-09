module Skylab::SubTree

  class Models::FileNode

    SubTree::Lib_::Tree_MMs_and_IMs[ self ]

    def initialize( * )
      super
      @tag_a = [ ]
      nil
    end

    attr_reader :tag_a

    def has_tag x
      @tag_a.include? x
    end

    def type= i
      @tag_a.length.zero? or fail '`type` is write once'
      @tag_a[ 0 ] = i
      index_self
      i
    end

    def slug= x
      has_slug and fail "sanity - slug collision"
      prepend_isomorphic_key x
      x
    end

    def destructive_merge_tag_a_notify otr, algo
      tag_a = otr.release_tag_a
      new_tag_a = algo.merge_union @tag_a, tag_a
      @tag_a = new_tag_a
      nil
    end

    def release_tag_a
      r = @tag_a ; @tag_a = nil ; r
    end

    def squash_only_child
      child = @box_multi.fetch_only_item
      destructive_merge child
      nil
    end

  private

    def transplant_box_multi_ownership_to otr
      r = @box_multi ; @box_multi = false ; @name_services = false
      r.ownership_transplant_notify otr
      r
    end

  private

    MERGE_ATTR_A_ = ( MERGE_ATTR_A_ + [ :tag_a ] ).freeze

    IDENTITY_ = -> x { x }

    Corresponding_business_filename_ = -> test_filename do
      # (to go in the other direction - to detect a corresponding test file
      # for a given business file, would be annoying and require filesystem
      # hits - the transformation we do above is a deterministic one-way
      # lossy one.)
      if (( md = PATH.test_basename_rx.match test_filename ))
        "#{ md.captures.detect( & IDENTITY_ )}#{
          }#{ Autoloader_::EXTNAME }"
      end
    end

    def index_self
      if has_tag :test
        if ! has_slug
          append_isomorphic_key '<ROOT>'
        else
          # (it would be nice if we could just check has_children but we aren't finished building yet..)
          if (( file = Corresponding_business_filename_[ slug ] ))
            # corresponding codefile
            add_isomorphic_key_with_metakey file, :codeish
          else
            # you look like not a test file so we assume you are a directory -
            # your c-odeish key is the same as your not codeish key:
            # (we used to add a metakey but no need for folders)
          end
        end
      end
    end
  end
end
