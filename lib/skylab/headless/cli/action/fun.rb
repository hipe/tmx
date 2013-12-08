module Skylab::Headless

  module CLI::Action

    FUN_ = ::Struct.new :summary_width

    FUN = FUN_.new( -> op, max=0 do  # hack a peek into o.p to decide how
      max = CLI::FUN::Summary_width[ op, max ] # wide to make column A
      max + op.summary_indent.length - 1  # (one space from o.p)
    end )

  end
end
