package skynet

object SkynetAsync extends App {
  import concurrent._, duration._
  import ExecutionContext.Implicits.global

  def skynet(num: Int, size: Int, div: Int): Future[Long] =
    if (size == 1) Future(num) else Future.sequence {
      (0 until div) map (i =>
        skynet(num + i * size / div, size / div, div))
    } map (_.sum)

  def run(n: Int): Long = {
    val start = System.nanoTime()
    val x = Await.result(skynet(0, 1000000, 10), Duration.Inf)
    val time = (System.nanoTime() - start) / 1000000
    println(s"$n. Result: $x in $time ms.")
    time
  }

  println(s"Best time ${(0 to 10) map (run) min} ms.")
}