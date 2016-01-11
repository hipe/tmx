module Skylab::SearchAndReplace

  class Interface_Models_::Replace

    # this isn't a UI model anymore so much as a custom intermediary -
    # it's responding to the activation of a buttonish association,
    # and is served as the receiver of a bound call for that action.
    #
    # this also acts as a readable parameter structure for the instream.
    # (at one point it housed around half of all the UI nodes!)

    def initialize & pp
      @_pp = pp
    end

    o = Parameters_[
      functions_directory: :_read,
      replacement_expression: :_read,
      streamer: nil,
    ]

    attr_writer( * o.symbols )

    attr_reader( * o.symbols( :_read ) )

    def to_file_session_stream  # assume no block

      @streamer.to_mutable_file_session_stream self, & @_pp
    end
  end
end
# #history: this used to hold almost half the content of all interface nodes
