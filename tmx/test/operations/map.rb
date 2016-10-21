module Skylab::TMX::TestSupport

  module Operations::Map

    def self.[] tcc
      TS_::Memoizer_Methods[ tcc ]
      Operations[ tcc ]
      tcc.send :define_singleton_method, :ordered_items_by, DEFINITION_FOR_ETC___
      tcc.include self
    end

    # -
      DEFINITION_FOR_ETC___ = -> & p do

        call_by( & p )

        shared_subject :presumably_ordered_items_ do
          _pray = operations_call_result_tuple.result
          _pray.to_a
        end
      end
    # -

    # -

      # -- assertions

      def order_is_ * exp_s_a

        _nodes = presumably_ordered_items_
        act = []
        _nodes.each do |node|
          act.push node.get_filesystem_directory_entry_string
        end
        if act != exp_s_a
          act.should eql exp_s_a
        end
      end

      # ~ assertion support

      def last_item_
        presumably_ordered_items_.fetch( -1 )
      end

      # -- setup

      def json_file_stream_01_

        # intentionally in dis-lexical order

        json_file_stream_ 'zagnut', 'frim_frum'
      end

      def json_file_stream_GA_

        # (to be "random", the below are in alphabetical order when each
        # word is read from back to front)

        json_file_stream_via_ %w(
          deka
          dora
          guld
          damud
          goah
          adder
          stern
          tyris
          gilius
          trix
        )
      end

      def json_file_stream_ * s_a
        json_file_stream_via_ s_a
      end

      def json_file_stream_via_ s_a
        Stream_.call s_a, & These___[]
      end

      def real_attributes_
        REAL_ATTRIBUTES___
      end

      REAL_ATTRIBUTES___ = [ :attributes_module_by, -> { Home_::Attributes_ } ]

    # -

    # ==

    These___ = Lazy_.call do

      # yes, to achieve more or less this same structure we could just glob
      # against the real filesystem rather than writing it by hand here, but
      # A) this way we can add entries for files that don't exist for testing
      # that, B) when using this structure it becomes explicit that we are
      # dictating the order these stream in and C) this way is less overhead

      h = {}

      dir = ::File.join FIXTURE_DIRECTORIES___, '01-fake-top-of-the-universe'

      same = "this.json"

      o = -> mid, tail=same do
        h[ mid ] = ::File.join dir, mid, tail
      end

      o[ "adder" ]   # 1 f 33
      o[ "damud" ]   # 2 f 44
      o[ "deka" ]    # 3 f 44
      o[ "dora" ]    # 4 s 3
      o[ "gilius" ]  # 5 s 4
      o[ "goah" ]    # 6 s 7
      o[ "guld" ]    # 7 s 7
      o[ "stern" ]   # 8 t 333
      o[ "trix" ]    # 9 t 333
      o[ "frim_frum", "any-name.json" ]
      o[ "tyris" ]   # 10 t 444
      o[ "zagnut", "any-other-name.json" ]

      -> s do
        h.fetch s
      end
    end

    # ==

    FIXTURE_DIRECTORIES___ = ::File.join TS_.dir_path, 'fixture-directories'
  end
end
