module Skylab::TMX

  class Reports_::Punchlist  # :[#005]

    # ## why an ordered punchlist
    #
    # whenever we have a largescale refactor that breaks lots of things,
    # it is convenient (probably optimal too) to have a general sense for
    # the order in which to fix the various sidesystems, where generally
    # the lower-level, more depended-upon nodes should be fixed first.
    #
    # in such a case what we do (conceptually if not actually) is create a
    # simple "to-do" list (or maybe it's a "burndown" list) of those
    # sidesystems that are broken by the change, ordered in such a way that
    # suggests a supposedly optimal path to fix them along.
    #
    # the ordering of this list is partly heuristic/aesthetic and partly
    # procedurally derived, but is nonetheless at its essence meant to
    # express what we call a "suggested regression order", a design objective
    # whose premise is that (to the extent that any node can be said to be
    # any more "low-level" than any particular other), it makes sense to
    # test the lower-level node earlier so that you can assume that the
    # broken code that is the subject of your test is not itself relying
    # on code that is broken but outside of the subject of your test.
    #
    # we say "heuristic/aesthetic" because in some cases we might give
    # a node an earlier priority than another only because that node was
    # designed that way (e.g a library node as opposed to an application
    # node); regardless of what might actually be true of the dependency
    # relationship for any two given nodes. but this ordering can also be
    # informed by the procedurally generated dependency graph visualized
    # by [#sl-001] (the "sidesystem dependency graph").
    #
    #
    #
    # ## why a versioned ordered punchlist template
    #
    # so that we would not have to go through the process of deciding on an
    # order for the invovled nodes every time we made a largescale change,
    # we started maintaining a versioned file ("punchlist.template" in
    # [sl]) that acted as sort of a template for this process: typically
    # we would copy-paste this "template" to a temporary file that would
    # serve as the burndown list for that development series. as nodes would
    # become green again they would be removed off the list until it was
    # empty, which established the overarching approach for largescale
    # refactors like this.
    #
    # (sometimes we would version this progressively shrinking like with
    # a name like "REDLIST" or similar. nowadays we would probably put
    # these items in the `.stack`.)
    #
    # some more details about this file:
    #
    #   - "punchlist.template" was sunsetted in the commit corresponding
    #     to the first entry of our #history noted at the end of this file.
    #
    #   - the actual ordering of this file (if you read it from top to
    #     bottom) was in fact "reverse regression order", with the lower-level
    #     entries appearing later (i.e "lower") in the file. this was done
    #     solely for the visual aesthetics of having the lower-level nodes
    #     appear visually lower in the file; but the "orientation" of any
    #     such file is relatively arbitary as long as the consuming agents
    #     know the orientation. (in the case of this file the consuming
    #     agent was the human.)
    #
    #
    #
    # ## why a generated punchlist
    #
    # this punchlist template was useful to this end but suffered from
    # the problems of maintenance, portability, and "aesthetic bias":
    #
    #   - maintencence: whenever we add, remove, or rename sidesystems
    #     we have to remember to update not only this list but every other
    #     similar list (e.g the GREENLIST). especially in the case of
    #     forgetting to add a new subsystem, the consequence can be
    #     particularly dire: we might think we have achieved universal
    #     integration when in fact we have not. these broken sidesystems
    #     or system then limp along silently in a potentially long history
    #     before they are noticed, making their eventual fixing more costly
    #     than if the integration issue(s) are detected earlier.
    #
    #   - portability: in a theoretical but much sought-after world where
    #     not all sidesystems shoudl be assumed to exist in a given
    #     installation, it's ugly if not problematic to list all sidesystems
    #     in the same "hard-coded" file. (this becomes [#001].)
    #
    #   - aesthetic bias: the ordering of the items is largely aesthetic/
    #     heuristic as discussed above; and so does not avail itself to
    #     being more data-driven.
    #
    # generating the punchlist only when needed (from reliable data) rather
    # than versioning it (for purposes outside of any one series); this
    # solves the first two problems, and avails itslef to interesting
    # solutions for the third problem.
    #
    #
    #
    # ## about the categories
    #
    # as well as being regression-oriented, the order was partly "aesthetic"
    # too, with the items placed into categories (one level deep). note that
    # categorization could be at odds with regression order (when you have
    # items that should go before/after other items in other categories,
    # ordering the items by category can conflict with the universal
    # regression order you want them in); but our categorization of the
    # items takes this factor into account: we designed the cateogories
    # to go in a regression order themselves, with each category being by
    # design more or less lower-level than the others. (:#spot-2)
    #
    # our expression of categories will only look right if the catorizations
    # have been written taking the regression order into account, otherwise
    # you would see the same categories "closed" and then "opened" multiple
    # times.
    #
    #
    # ## known issues/wishlist
    #
    #   - wishlist: tree not chain, maybe

    def initialize o, & emit
      @_emit = emit
      @__json_file_stream = o.json_file_stream
    end

    def execute

      @_item_stream = Home_::API.call(
        :map,
        :json_file_stream, ( remove_instance_variable :@__json_file_stream ),
        :attributes_module_by, -> { Home_::Attributes_ },
        :order, :after,
        :select, :category,
        & @_emit
      )

      @_current_category = nil
      @_state = :__first_line

      Common_.stream do
        send @_state
      end
    end

    def __first_line
      if _there_is_a_next_node
        @_current_category = _the_category_of_the_node
        _say_the_category_then_the_node
      else
        _this_is_the_end_of_the_stream
      end
    end

    def __normally
      if _there_is_a_next_node
        if __the_category_is_the_same_as_the_current_category
          _say_the_node
        else
          __say_a_blank_line_then_the_category_then_the_node
        end
      else
        _this_is_the_end_of_the_stream
      end
    end

    def _there_is_a_next_node
      @_node = @_item_stream.gets
      @_node && ACHIEVED_
    end

    def _this_is_the_end_of_the_stream
      remove_instance_variable :@_item_stream
      remove_instance_variable :@_state
      NOTHING_
    end

    def __the_category_is_the_same_as_the_current_category
      cat = _the_category_of_the_node
      if @_current_category == cat
        TRUE
      else
        @_current_category = cat
        FALSE
      end
    end

    def _the_category_of_the_node
      @_node.box.fetch :category
    end

    def __say_a_blank_line_then_the_category_then_the_node
      @_state = :_say_the_category_then_the_node
      EMPTY_S_
    end

    def _say_the_category_then_the_node
      @_state = :__say_the_node_then_change_the_state
      "# #{ @_current_category }"
    end

    def __say_the_node_then_change_the_state
      @_state = :__normally
      _say_the_node
    end

    def _say_the_node
      @_node.filesystem_directory_entry_string
    end
  end
end
# #history: born to replace #tombstone: the static punchlist.template
