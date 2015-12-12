
sealed trait ConnectionHeader {
  def willClose: Boolean
  def header: Option[String]
}

object ServerResultUtils {
  def splitSetCookieHeaders(headers: Map[String, String]): Iterable[(String, String)] = {
    // ..
  }
}
