class String
  def deindent
    gsub(%r{^#{Regexp.escape match(/\A([[:space:]]*)/)[1]}}, '').strip
  end
end

