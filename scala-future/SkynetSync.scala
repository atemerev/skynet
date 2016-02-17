package skynet

object SkynetSync extends App {

  def skynet(num: Int, size: Int, div: Int): Long =
    if (size > 1) (0 until div).map(i =>
      skynet(num + i * size / div, size / div, div)).sum
    else num

  def run(n: Int): Long = {
    val start = System.nanoTime()
    val x = skynet(0, 1000000, 10)
    val time = (System.nanoTime() - start) / 1000000
    println(s"$n. Result: $x in $time ms.")
    time
  }

  println(s"Best time ${(0 to 10) map (run) min} ms.")
}