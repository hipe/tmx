class Hipe::CssConvert::DirectivesRunner
  def initialize(ctx)
    @c = ctx
  end
  def run directives_sexp
    @c.out.puts "ok running haha yeah right"
  end
end
