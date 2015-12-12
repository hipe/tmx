
private[common] class NodeIdentifierParser(version: ForwardedHeaderVersion) extends RegexParsers {

  def parseNode(s: String): Either[String, (IpAddress, Option[Port])] = {
    // ..
  }
}
