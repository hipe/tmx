module Skylab::SearchAndReplace

  class Magnetics_::All_Remaining_via_Parameters

    def initialize & p
      @_listener = p
    end

    attr_writer(
      :expression_agent,
      :file_UOW,
      :gets_one_next_file,
      :serr,
    )

    def execute

      ok = ACHIEVED_
      __init_totals
      begin
        uow = @file_UOW
        ok_ = uow.engage_all_remaining_in_file
        ok_ &&= uow.maybe_write
        if ok_
          __express_item_summary
          __add_to_totals
        else
          @_total_number_of_files_with_errors += 1
          ok = ok_
        end

        if uow.has_next_file
          @file_UOW = @gets_one_next_file[]
          redo
        end
        break
      end while nil
      __express_job_summary
      ok
    end

    def __express_item_summary

      # e.g "wrote file 1 (3 replacements in 4 matches, 107 dry bytes) - [path]"
      #     "wrote file 2 (2 replacements, 108 bytes) - [path]"
      #     "file 3 (0 matches) - [path]"

      # because #OCD we are writing to the stderr directly rather than
      # emit an event for every file. (1000 is 1000 is 1000)

      _ = @file_UOW.say_wrote_under @expression_agent
      @serr.puts "#{ _ } - #{ @file_UOW.path }"
      NIL_
    end

    def __init_totals

      @_total_matches = 0
      @_total_number_of_files_with_errors = 0
      @_total_number_of_files_without_errors = 0
      @_total_replacements = 0 ; nil
    end

    def __add_to_totals

      uow = @file_UOW
      @_total_matches += uow.match_count
      @_total_number_of_files_without_errors += 1
      @_total_replacements += uow.engaged_count ; nil
    end

    def __express_job_summary

      er_tot = @_total_number_of_files_with_errors
      fi_tot = @_total_number_of_files_without_errors
      ma_tot = @_total_matches
      rp_tot = @_total_replacements

      @_listener.call :info, :expression, :job_summary do |y|

        done = '. done.'
        if er_tot.nonzero?
          done_ = done ; done = nil
        end

        s = "("
        s << "#{ rp_tot } replacement#{ s rp_tot }"
        if rp_tot != ma_tot
          s << " of #{ ma_tot } #{ plural_noun ma_tot, 'match' }"
        end
        s << " in #{ fi_tot } file#{ s fi_tot }#{ done })"

        y << s

        if er_tot.nonzero?
          y << "#{ er_tot } file#{ s er_tot } had error(s)#{ done_ }"
        end
      end
    end
  end
end
