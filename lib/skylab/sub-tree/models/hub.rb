module Skylab::SubTree

  class Models::Hub

    Lib_::Basic_Fields[ :client, self,
      :absorber, :absrb_iambic_fully,
      :field_i_a, [ :test_dir_pn, :sub_path_a, :local_test_pathname_ea,
                   :lister_p, :info_tree_p ] ]

    def initialize *x_a  # #yes-globbed
      @did_show_debubbing_output = false
      @sub_hub_pn = nil
      absrb_iambic_fully x_a ; nil
    end

    def get_tree_combined
      prepare
      code_tree_notify(( c = build_code_tree ))
      test_tree_notify(( t = build_test_tree c ))
      if ! @did_show_debubbing_output
        perform_destructive_merge c, t
        c
      end
    end

  private

    def prepare
      @did_show_debugging_output = false
      @lister = @lister_p.call
    end

    def code_tree_notify t
      tree_notify :code_tree, t
    end

    def test_tree_notify t
      tree_notify :test_tree, t
    end

    def tree_notify i, t
      if (( @lister && @lister.do_list_tree( i ) ))
        @did_show_debubbing_output = true
        @info_tree_p[ LABEL_H_.fetch( i ), t ]
      end
      nil
    end

    LABEL_H_ = {
      code_tree: 'code tree',
      test_tree: 'test tree'
    }.freeze

    def build_code_tree
      code_path_a = get_code_path_a
      ct = Models::FileNode.from :paths, code_path_a,
        :init_node, -> n { n.type = :code }
      case ct.children_count
      when 0
        ct.slug = '(no code)'
      when 1
        ct = ct.fetch_first_child
      else
        fail "sanity - not a stem tree?"
      end
      ct
    end

    def get_code_path_a
      self.class::Code_glob_[ :app_hub_pn, app_hub_pn,
        :test_dir_pn, @test_dir_pn, :sub_path_a, @sub_path_a ]
    end

    def app_hub_pn
      @app_hub_pn ||= @test_dir_pn.dirname
    end

    def build_test_tree code_tree
      ct = code_tree
      test_path_a = get_test_path_a
      t = Models::FileNode.from :paths, test_path_a,
        :init_node, -> n { n.type = :test }
      case t.children_count
      when 0
        t.slug = '(no tests)'
      when 1
        t = self.class::Test_squash_[
          :app_hub_pn, app_hub_pn, :test_dir_pn, @test_dir_pn, :tree, t ]
      else
        fail "sanity - non-stem tree?"
      end
      s = ct.slug
      if ! t.is_under_isomorphic_key s
        fail 'where?'  # #todo
        t.add_isomorphic_key_with_metakey s, :codeish
          # hack an association of the two trees if necessary
      end
      t
    end

    def get_test_path_a
      self.class::Test_glob_[
        @test_dir_pn, @sub_path_a, local_test_pathname_a ]
    end

    def local_test_pathname_a
      @local_test_pathname_a ||= @local_test_pathname_ea.to_a.freeze
    end

    EXTNAME_ = Autoloader_::EXTNAME

    def perform_destructive_merge c, t
      c.destructive_merge t, :key_proc, KEY_PROC_
      nil
    end

    KEY_PROC_ = -> n do
      if ! n.has_tag :test
        n.slug
      else
        slug = n.fetch_isomorphic_key_with_metakey( :codeish ){ }  # tricky point
        if slug
          slug
        else
          n.slug  # assume node is test subdirectory
        end
      end
    end

  public  #   ~ auxiliary services ~

    def get_sub_hub_pn
      if @sub_path_a
        @test_dir_pn.join @sub_path_a.join( SEP_ )
      else
        @test_dir_pn
      end
    end

    #  ~ dubious services ~

    def path_moniker_stem
      @test_dir_pn.to_s
    end

    def _local_test_pathname_a
      local_test_pathname_a
    end

    def relative_path_to short_pathname
      if @sub_path_a
        r = [ * @sub_path_a, short_pathname.to_s ].join SEP_
      else
        r = short_pathname.to_s
      end
      r
    end
  end
end
