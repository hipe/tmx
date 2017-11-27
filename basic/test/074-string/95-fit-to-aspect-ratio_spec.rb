require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - fit to aspect ratio" do

    TS_[ self ]
    use :word_wrapper_calm

    it "target aspect ratio of 2:3 against 4 pairs" do

      ww = subject_with_(
        :aspect_ratio, [ 2, 3 ],
        :downstream_yielder, [] )

      ww << 'ab'
      ww << 'cd ef'
      ww << 'gh'

      expect( ww.flush ).to eql %w( ab cd ef gh )
    end

    it "target aspect ratio of 3:2 against 4 pairs" do

      ww = subject_with_(
        :aspect_ratio, [ 3, 2 ],
        :downstream_yielder, [] )

      ww << 'ab cd'
      ww << 'ef gh'

      expect( ww.flush ).to eql [ 'ab cd', 'ef gh' ]
    end


    it "a more attractive fit wins over a closer aspect ratio (widen)" do

      _a = subject_via_(
        :aspect_ratio, [ 8, 3 ],
        :downstream_yielder, [],
        :input_string, 'never re-think it' )

      #     'never',
      #     're-think',
      #     'it'
      #
      # the rectangle that bounds the above is exactly 8:3
      # yet the below more attractive delineation is chosen:

      expect( _a ).to eql [ 'never re-', 'think it' ]
    end

    it "a more attractive fit wins over a closer aspect ratio (shrinken)" do

      _a = subject_via_(
        :aspect_ratio, [ 11, 2 ],
        :downstream_yielder, [],
        :input_string, 'i love this city' )

      #     'i love this'
      #     'city'
      #
      # the above delineation fits perfectly into an 11:2 rectangle,
      # yet the below more attractive delineation is chosen:

      expect( _a ).to eql [ 'i love', 'this city' ]
    end

    it "reduction / lockdown (taller)" do

      expect( subject_via_(
        :aspect_ratio, [ 5, 1 ],
        :downstream_yielder, [],
        :input_words, %w( chaos computer collective )

      ) ).to eql %w( chaos computer collective )
    end

    it "reduction / lockdown (wider)" do

      expect( subject_via_(
        :aspect_ratio, [ 16, 3 ],
        :downstream_yielder, [],
        :input_words, %w( chaos computer collective )

      ) ).to eql [ "chaos computer", "collective" ]
    end
  end
end
