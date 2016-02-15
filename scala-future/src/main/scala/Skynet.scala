import scala.concurrent._
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._

object Root extends App {
  def skynet(num: Int, size: Int, div: Int): Future[Long] = {
    if(size == 1)
	  Future(num.toLong)
	else {
	  Future.sequence((0 until div).map(n => skynet(num + n*(size/div), size/div, div))).map(_.sum)
	}
  }
  // warm-up
  Await.result(skynet(0, 1000000, 10), 10.seconds)
  Await.result(skynet(0, 1000000, 10), 10.seconds)
  val startTime = System.nanoTime()
  val x = Await.result(skynet(0, 1000000, 10), 100.seconds)
  val diffMs = (System.nanoTime() - startTime) / 1000000
  println(s"Result: $x in $diffMs ms.")
}
