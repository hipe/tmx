module Skylab::DocTest::TestSupport

  module Recursion_Magnetics

    class << self
      def [] tcc
        tcc.include self
      end

      define_method :o, TestSupport_::DANGEROUS_MEMOIZE
    end  # >>

    o :some_real_magnetics_directory_ do
      # this is one that depends on the real filesystem
      ::File.join my_real_counterpart_directory_, 'recursion-magnetics-'
    end

    o :my_real_test_directory_ do
      ::File.join sidesystem_path_, 'test'
    end

    o :my_real_counterpart_directory_ do
      ::File.join sidesystem_path_, 'lib', 'skylab', 'doc_test'
    end

    def imaginary_path_one_two__
      ::File.join sidesystem_path_, 'one', 'two'
    end

    def normalize_real_test_file_path__ path
      # this craziness is explained in [#029] #note-1
      _omg = path.reverse
      scn = Home_::RecursionModels_::EntryScanner.via_path_ _omg
      egads = []
      test_backwards = 'tset'  # "test"
      begin
        entry = scn.scan_entry
        entry || Home_._SANITY
        if test_backwards == entry
          break
        end
        egads.push entry.reverse
        redo
      end while above
      ::File.join my_real_test_directory_, * egads.reverse
    end

    def selfsame_name_conventions_
      _name_conventions_node.default_instance__
    end

    o :tite_fake_name_conventions_ do
      o = _name_conventions_node.default_instance__.dup
      o.asset_extname = '.ko'
      o.test_filename_patterns = [ '*_speg.ko' ]
      o.finish
    end

    o :longer_fake_name_conventions__ do
      o = _name_conventions_node.default_instance__.dup
      o.asset_extname = '.kode'
      o.test_filename_patterns = [ '*_speg.kode' ]
      o.finish
    end

    def _name_conventions_node
      Home_::RecursionModels_::NameConventions
    end
  end
end
