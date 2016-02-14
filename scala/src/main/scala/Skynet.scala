import akka.actor.{ ActorSystem, Props, ActorRef, Actor }

object Skynet {
  val props = Props(new Skynet)
  case class Start(level: Int, num: Long)
}

class Skynet extends Actor {
  import Skynet._

  var todo = 10
  var count = 0L

  def receive = {
    case Start(level, num) =>
      if (level == 1) {
        context.parent ! num
        context.stop(self)
      } else {
        val start = num * 10
        (0 to 9) foreach (i => context.actorOf(props) ! Start(level - 1, start + i))
      }
    case l: Long =>
      todo -= 1
      count += l
      if (todo == 0) {
        context.parent ! count
        context.stop(self)
      }
  }
}

class Root extends Actor {
  import Root._

  override def receive = {
    case Run(n) => startRun(n)
  }

  def startRun(n: Int): Unit = {
    val start = System.nanoTime()
    context.actorOf(Skynet.props) ! Skynet.Start(7, 0)
    context.become(waiting(n - 1, start))
  }

  def waiting(n: Int, start: Long): Receive = {
    case x: Long =>
      val diffMs = (System.nanoTime() - start) / 1000000
      println(s"Result: $x in $diffMs ms.")
      if (n == 0) context.system.terminate()
      else startRun(n)
  }
}

object Root extends App {
  case class Run(num: Int)

  ActorSystem("main").actorOf(Props[Root]) ! Run(3)
}
