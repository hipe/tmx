require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] algorithm - bucket list that is fairly distributed [..]" do

    TS_[ self ]
    use :memoizer_methods

    it "loads" do
      _subject_module || fail
    end

    it "a first example" do

      buckets = _subject_module[ _presidents_as_stream, 3 ]

      buckets.length.should eql 3

      # from partitioning the list by hand, we got:
      #   486    455    562
      #   taft  clev  trump
      #   jack  obam   bush
      #                madi

      buckets.map( & :total ).should eql [ 486, 455, 562 ]
    end

    it "what about zeros? zeros are distributed as well" do

      a = []
      o = -> s, d do
        a.push X_algo_etc_MyStruct[ d, s ]
      end
      o[ :w, 10 ]
      o[ :x, 0 ]
      o[ :y, 20 ]
      o[ :z, 0 ]

      buckets = _subject_module[ Stream_[ a ], 2 ]
      2 == buckets.length || fail
      first_bucket, second_bucket = buckets
      first_bucket.children_count == 2 || fail
      second_bucket.children_count == 2 || fail

      first_bucket.total == 20 || fail
      second_bucket.total == 10 || fail

      first_bucket.instance_variable_get( :@_tuples ).last._ID_x_ == :x || fail
      second_bucket.instance_variable_get( :@_tuples ).last._ID_x_ == :z || fail
    end

    def _presidents_as_stream
      Stream_[ __presidents_array ]
    end

    shared_subject :__presidents_array do  # ick/meh. maybe push up somehow..

      path = ::File.join(
        Home_::Algorithm.dir_path,
        Common_::Name.via_module( _subject_module ).as_slug,
      )
      path << Common_::Autoloader::EXTNAME

      io = ::File.open path, ::File::RDONLY

      find = "the heaviest few, the lightest few,"
      begin
        line = io.gets
      end until line.include? find
      find = nil

      _blankish = io.gets
      _blankish =~ /\A[ ]+[#]$/ || fail

      NEWLINE_ = "\n"  # ..

      a = [] ; line = nil

      rx = /\A[ ]{4}#[ ]{3}(?<name>[.a-z]+(?: [.a-z]+)*)[ ]+(?<weight>\d+)$/
      add_line = -> do
        md = rx.match line
        a.push X_algo_etc_MyStruct[ md[ :weight ].to_i, md[ :name ] ]
      end

      line = io.gets
      add_line[]
      begin
        line = io.gets
        line == NEWLINE_ && break
        add_line[]
        redo
      end while above

      io.close
      a.freeze
    end

    def _subject_module

      Home_::Algorithm::
        BucketList_that_is_FairlyDistributed_via_WeightedTupleStream_and_N_Buckets
    end

    X_algo_etc_MyStruct = ::Struct.new :main_quantity, :_ID_x_
  end
end
