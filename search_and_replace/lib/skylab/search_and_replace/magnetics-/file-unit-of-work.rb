module Skylab::SearchAndReplace

  class Magnetics_::File_Unit_of_Work

    # stands as an adapter between the custom view controller and the file
    # edit session. accumulates statistics used in summary reporting.
    #
    # the prototype keeps track of how many instances have been created.
    #
    # the instance keeps track of the count of matches that are engaged.
    #
    # the instance knows how to (and whether to) write the file.
    #
    # it started as spillover from the custom view controller: whereas that
    # operates on several files, this only has to worry about one.
    #
    # as it is it may seem misplaced here because of its tight coupling
    # to the view controller. however we may also try to use this same node
    # if we ever give the API the ability to write files for itself, rather
    # than resulting in a stream of file edit sessions as it does now. so
    # note that while at present, the UI is its only client, the code here
    # is not married to that modality.

    class << self

      def prototype  & oes_p
        new( & oes_p )
      end

      def the_empty_unit_of_work
        The_emtpy_unit_of_work___[]
      end

      private :new
    end

    def initialize & oes_p
      @instance_count = 0
      @_oes_p = oes_p
    end

    # -- as proto

    def instance_count
      @instance_count  # warnings
    end

    # -- as instance

    def via_two sess, sess_
      if sess
        @instance_count += 1
        otr = dup
        otr.___init sess, sess_
      else
        self._B
      end
    end

    def ___init sess, sess_  # assume first `sess` :#here-1

      @instance_ordinal = remove_instance_variable :@instance_count

      if sess_
        hnf = true
        @_next_file_session = sess_
      end

      fmc = sess.first_match_controller
      if fmc
        cmci = 0
        @current_match_controller = fmc
        if fmc.next_match_controller
          hnmc =  true
        end
      end

      @current_match_controller_index = cmci
      @engaged_count = 0
      @_file_session = sess
      @__has_next_file = hnf
      @_has_next_match_controller = hnmc
      @_max_match_controller_index = cmci
      self
    end

    # ~ file-related

    def maybe_write
      @bytes = nil
      @did_write = false
      @was_dry = false

      if @engaged_count.zero?
        ACHIEVED_
      else
        ___do_write
      end
    end

    def ___do_write  # assume relevant ivars have default values

      _st = @_file_session.to_line_stream

      o = Home_::Magnetics_::Write_changed_file_via_mutable_file_session.
        new( & @_oes_p )  # misnomer

      o.line_stream = _st
      o.path = path

      is_dry = @_file_session.is_dry_run

      o.write_is_enabled = ! is_dry

      @was_dry = is_dry

      wrote = o.execute
      if wrote
        @bytes = wrote.bytes
        @did_write = true
        ACHIEVED_
      else
        wrote
      end
    end

    def say_wrote_under expag  # (kinda nasty here, but useful)

      # e.g "wrote file 1 (3 replacements in 4 matches, 107 dry bytes)
      #     "wrote file 2 (2 replacements, 108 bytes)
      #     "file 3 (0 matches)

      a = []
      if @did_write
        a.push SURFACE_VERB___
      end
      a.push "file #{ @instance_ordinal }"

      me = self
      mat_d = match_count
      rep_d = @engaged_count

      expag.calculate do

        s = "#{ rep_d } replacement#{ s rep_d }"
        if mat_d != rep_d
          s << " in #{ mat_d } #{ plural_noun mat_d, MATCH___ }"
        end
        a_ = [ s ]

        if me.did_write
          if me.was_dry
            _dry = DRY___
          end
          a_.push "#{ me.bytes }#{ _dry } bytes"
        end
        a.push "(#{ a_.join COMMA___ })" ; nil
      end

      a.join SPACE_
    end

    COMMA___ = ', ' ; DASH_ = '-'
    DRY___ = ' dry' ; MATCH___ = 'match' ; SURFACE_VERB___ = 'wrote'

    attr_reader(
      :bytes,
      :did_write,
      :was_dry,
    )

    def has_next_file
      @__has_next_file
    end

    def path
      @_file_session.path
    end

    def has_file  # assume #here-1
      true
    end

    def next_file_session
      @_next_file_session  # warnings
    end

    # ~ match-related

    # ~~ macro

    def engage_all_remaining_in_file  # assume current match

      ok = ACHIEVED_
      begin

        if ! @current_match_controller.replacement_is_engaged
          ok_ = _engage_current_match_which_is_disengaged
          if ! ok_
            ok = ok_
          end
        end

        if @_has_next_match_controller
          move_to_next_match
          redo
        end
        break
      end while nil
      ok
    end

    # ~~ when previous match

    def has_previous_match
      d = @current_match_controller_index
      d && d.nonzero?
    end

    def move_to_previous_match  # assume above

      pmc = @current_match_controller.previous_match_controller
      pmci = @current_match_controller_index - 1

      @current_match_controller = pmc
      @current_match_controller_index = pmci
      @_has_next_match_controller = true
      NIL_
    end

    # ~~ when current match

    def has_current_match
      ! @current_match_controller_index.nil?
    end

    # ~~~ assume current match

    def toggle_current_match_is_engaged

      cmc = @current_match_controller
      if cmc.replacement_is_engaged
        ok = cmc.disengage_replacement
        if ok
          @engaged_count -= 1
        end
      else
        ok = _engage_current_match_which_is_disengaged
      end
      ok
    end

    def _engage_current_match_which_is_disengaged
      ok = @current_match_controller.engage_replacement( & @_oes_p )  # RESULT
      if ok
        @engaged_count += 1
      end
      ok
    end

    def replacement_is_engaged_of_current_match
      @current_match_controller.replacement_is_engaged
    end

    def ordinal_of_current_match
      @current_match_controller_index + 1
    end

    def index_of_current_match
      @current_match_controller_index
    end

    # ~~ when next match

    def has_next_match
      @_has_next_match_controller
    end

    # ~~~ assume next match

    def move_to_next_match  # assume above

      nmci = @current_match_controller_index + 1
      next_mc = @current_match_controller.next_match_controller

      if next_mc.next_match_controller
        hnmc = true
      end

      if nmci > @_max_match_controller_index
        @_max_match_controller_index = nmci
      end

      @current_match_controller = next_mc
      @current_match_controller_index = nmci
      @_has_next_match_controller = hnmc
      NIL_
    end

    # ~~

    def match_count
      @_max_match_controller_index + 1
    end

    attr_reader(
      :current_match_controller,
      :engaged_count,
      :instance_ordinal,
    )

    The_emtpy_unit_of_work___ = Lazy_.call do

      # an empty unit of work so client code doesn't have to use
      # conditionals everywhere. typically used at the end of a "job".

      class Null_Stub____

        def has_file
          false
        end

        def has_next_file
          false
        end

        def has_previous_match
          false
        end

        def has_current_match
          false
        end

        def has_next_match
          false
        end

        def engaged_count
          0
        end

        self
      end.new
    end
  end
end
