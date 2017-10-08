require_relative '../../test-support'

module Skylab::BeautySalon::TestSupport

  describe '[bs] crazy-town magnetics - NPvM - limited inheritence', ct: true do

    TS_[ self ]
    use :memoizer_methods
    use :crazy_town_THIS_STUFF

    # NOTE - there is a quirk to using inheritence that is either OK or
    # icky depending on perspective:
    #
    #   1) we don't want to have any classes under Items that are not
    #      grammar symbol classes that correspond to real grammar elements.
    #
    #   2) as such, an abstract base class should be housed outside of
    #      (and above) the Items module.
    #
    #   3) in practice all base classes will be abstract, because there
    #      is no inherit-and-modify (associations) (i.e it's not true
    #      inheritence, just re-use of definitions); and as such, to make
    #      this non-abstract inheritence would introduce a non-justifiable
    #      asymmetry.
    #
    #   4) that's not the problem tho. the thing is that when a class's
    #      association *definitions* are *realized*, it needs to have
    #      access to the (whatever it's called) services object, that
    #      does things like resolve group (type) names.
    #
    #   5) the only way (4) happens is when the class is dereferenced
    #      (the first time). and this is OK, this is the way it should be.
    #      (at least, for our current scope.)
    #
    #   6) but so note we have neither the need nor the ability to
    #      dereference these base classes (per (1)); and per (5) we cannot
    #      realize the association definitions without first dereferencing
    #      the class. as such we cannot "see" the associations of abstract
    #      base classes directly.
    #
    # in practice this is OK because it all "just works" and doesn't look
    # weird, but in the test we have to step around this limitation in
    # order to prove what we want to prove (i.e true re-use without
    # prying into implementation detail).

    context 'a child class descends from a base class' do

      it 'the one child has the associations' do

        _has_these_two _one_assocs_index
      end

      it 'the other child has the associations (referenced after above)' do

        _has_these_two _state2
      end

      it 'the associations that the two chidren have are THE SAME objects' do

        ai = _one_assocs_index
        ai_ = _state2

        a = ai.associations
        a_ = ai_.associations

        a.first.object_id == a_.first.object_id || fail
        a.last.object_id == a_.last.object_id || fail

        # .. bonus round:

        ai.object_id == ai_.object_id || fail

        a.object_id == a_.object_id || fail
      end

      def _has_these_two ai
        a = ai.associations
        a.first.stem_symbol == :thing_one || fail
        a.last.stem_symbol == :thing_two || fail
      end

      def _one_assocs_index
        _state1.first
      end

      shared_subject :_state2 do

        _fb = _state1.last
        _cls = _fb.dereference :another_child
        _x = _cls.children_association_index
      end

      shared_subject :_state1 do

        fb = _state_0
        _cls = fb.dereference :one_child
        _x = _cls.children_association_index
        [ _x, fb ]
      end

      shared_subject :_state_0 do

        base_cls = _this_one_base_class

        chld_cls_1 = ::Class.new base_cls
        chld_cls_2 = ::Class.new base_cls

        build_subject_branch_(
          chld_cls_1, :OneChild,
          chld_cls_2, :AnotherChild,
          :ThisOneGuy,
        )
      end
    end

    it 'borks if you try to add do true inheritence', ex: true do

      _base_cls = _this_one_base_class

      chld_cls = ::Class.new _base_cls
      sandbox_module_.const_set :Case01, chld_cls
      e = nil
      here = subject_magnetic_
      chld_cls.class_exec do
        begin
          children(
            :thing_three_xx_terminal,
          )
        rescue here::MyException__ => e
        end
      end

      e.symbol == :cannot_redefine_or_add_to_any_existing_children_definition || fail
    end

    shared_subject :_this_one_base_class do

      # NOTE - this will mutate over the course of the stories in this file.
      # the only reason this isn't dangerous is that we have a priori
      # knowledge of how one of the behaviors-under-test works; that it
      # won't interfere.

      build_subclass_with_these_children_( :Case01_Base,
        :thing_one_xx_terminal,
        :thing_two_xx_terminal,
      )
    end

    # --

    def sandbox_module_
      X_ctm_npvm_li
    end

    X_ctm_npvm_li = ::Module.new  # const namespace for tests in this file
  end
end
# #born.
