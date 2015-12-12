trait WebSocketable {
  def getHeader(header: String): String
  def check: Boolean
}
