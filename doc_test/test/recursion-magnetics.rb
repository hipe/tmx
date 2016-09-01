module Skylab::DocTest::TestSupport

  module Recursion_Magnetics

    class << self
      def [] tcc
        tcc.include self
      end

      define_method :o, TestSupport_::DANGEROUS_MEMOIZE
    end  # >>

    o :my_real_magnetics_directory_ do
      # this is one that depends on the real filesystem
      ::File.join my_real_counterpart_directory_, 'magnetics-'
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

    o :name_conventions_ do
      o = Home_::RecursionModels_::NameConventions.begin
      o.asset_filename_pattern = '*.kode'
      o.finish
    end
  end
end
