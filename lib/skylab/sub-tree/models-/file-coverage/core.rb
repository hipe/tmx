module Skylab::SubTree

  module Models_::File_Coverage

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

    class Actions::File_Coverage < SubTree_::API::Action

      @is_promoted = true

      def initialize( * )
        @be_verbose = false  # placeholder
        super
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

  if false

  class API::Actions::Cov < API::Action

    Local_Actor_.call self, :simple, :properties,

      :iambic_writer_method_to_be_provided,
        :ivar, :@list_as_a, :property, :list_as,

      :required, :property, :path,

      :flag, :ivar, :@be_verbose, :property, :verbose

    def initialize _
      @list_as_a = []
      super
    end

  private

    # API action hook-(out/in)s we implement are `normalize`, `execute`

    def list_as=
      @list_as_a.push iambic_property
    end

    def normalize
      ok = nrmlz_path
      ok && resolve_list_behavior
    end

    def nrmlz_path
      md = STRIP_TRAILING_RX_.match @path
      if md
        @path = md[ :no_trailing ]
        PROCEDE_
      else
        whine_about_invalid :path, '{{ noun }} looks funny: {{ x }}'
      end
    end

    STRIP_TRAILING_RX_ = %r{ \A (?<no_trailing> / | .* [^/] ) /* \z }x

    def resolve_list_behavior
      @hub_a = bld_hub_a
      @hub_a and via_hub_array_resolve_list_behavior
    end

    # ~ build hub array

    def bld_hub_a
      us = bld_upstream
      @sub_path_a = us.sub_path_array
      scn = us.test_dir_pathnames
      scn and begin
        @hub_yieldee = []
        while @child_path = scn.gets
          via_child_path
        end
        a = @hub_yieldee ; @hub_yieldee = @test_dir_pn = nil ; a
      end
    end

    def bld_upstream
      Cov_::Model_Agents__::Upstream::Via_Filesystem.new :path, @path,
        :be_verbose, ( @be_verbose || false ), # is strict about validation
        :on_event_selectively, handle_event_selectively
    end

    def via_child_path
      dpn = ::Pathname.new @child_path
      baseglob = GLOB_H_.fetch dpn.basename.to_s
      sub_dir = if @sub_path_a
        dpn.join( @sub_path_a * SEP_ )
      else
        dpn
      end
      _glob = sub_dir.join( "**/#{ baseglob }" ).to_s
      yield_hub_object dpn, _glob, sub_dir
      nil
    end

    GLOB_H_ = SubTree_::PATH.glob_h

    def yield_hub_object dpn, glob, sub_dir
      _hub = SubTree_::Models::Hub.new(
        :test_dir_pn, dpn,
        :sub_path_a, @sub_path_a,
        :list_behavior_proc, -> do
          @list_behavior
        end,
        :info_tree_p, -> label, tree do
          receive_info_tree label, tree
        end,
        :local_test_pathname_scan_proc, -> do
          entry_a = ::Dir[ glob ]
          Callback_::Stream.via_nonsparse_array entry_a do | entry_s |
            _spec_pn = ::Pathname.new entry_s
            _spec_pn.relative_path_from sub_dir
          end
        end )
      @hub_yieldee.push _hub
      nil
    end

    # ~

    def via_hub_array_resolve_list_behavior

      @list_behavior = Cov_::Actors__::Build_list_behavior.with(
        :hubs, @hub_a,
        :argument_symbol_list, @list_as_a,
        :on_event_selectively, handle_event_selectively )
      @list_behavior ? ACHIEVED_ : UNABLE_
    end


    # ~ HERE ~

    def execute
      @list_as = @list_behavior.special_format_symbol
      if @list_as
        when_special_format_execute
      else
        when_tree_execute
      end
    end

    def when_special_format_execute  # assume list_behavior is normal
      @list_behavior.resolve_and_send_events
      nil
    end

    def when_tree_execute
      if @hub_a.length.zero?
        when_no_directory
      else
        Cov_::Actors__::Produce_uber_tree.with(
          :path, @path,
          :hub_a, @hub_a,
          :on_event_selectively, handle_event_selectively )
      end
    end

    def when_no_directory
      maybe_send_event :error, :no_directory do
        No_Directory__[ @path ].to_event
      end
      UNABLE_
    end

    Message_ = Callback_::Event.message_class_factory

    No_Directory__ = Message_.new do |path|
      pn = ::Pathname.new path
      pn_ = pn.join SubTree_::PATH.test_dir_names_moniker
      "Couldn't find test directory: #{ pth pn_ }"
    end

    ACHIEVED_ = true

    Cov_ = self

    Data_Event_ = Data_Event_

    TEST_DIR_NAME_A_ = SubTree_::Lib_::Test_dir_name_a[]
  end
  end

    end

    Autoloader_[ Actors_ = ::Module.new ]

    File_Coverage_ = self

    FILENAMES___ = SubTree_::Lib_::Test_dir_name_a[]

  end
end