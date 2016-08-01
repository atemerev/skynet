package skynet

import java.util.concurrent.TimeUnit

import org.openjdk.jmh.annotations._

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent._
import scala.concurrent.duration._

@BenchmarkMode(Array(Mode.AverageTime))
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@State(Scope.Thread)
@Warmup(iterations = 20)
@Measurement(iterations = 20)
@Fork(20)
class Skynet {

  def skynetAsync(num: Int, size: Int, div: Int): Future[Long] =
    if (size == 1) Future(num)
    else Future.sequence {
      (0 until div) map (i => skynetAsync(num + i * size / div, size / div, div))
    } map (_.sum)

  def skynetSync(num: Int, size: Int, div: Int): Long =
    if (size > 1) (0 until div).map(i =>
      skynetSync(num + i * size / div, size / div, div)).sum
    else num

  @Benchmark
  def skynetAsyncBench(): Long = {
    Await.result(skynetAsync(0, 1000000, 10), Duration.Inf)
  }

  @Benchmark
  def skynetSyncBench(): Long = {
    skynetSync(0, 1000000, 10)
  }
}
