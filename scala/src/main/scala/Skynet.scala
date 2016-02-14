import akka.actor.{ActorSystem, Props, ActorRef, Actor}

class Skynet(parent: ActorRef, num: Int, size: Int, div: Int) extends Actor {

  var received = 0
  var total = 0L

  size match {
    case 1 => parent ! num.toLong
    case x if x > 1 => (0 until div).map(mkChild)
  }

  override def receive = {
    case x: Long => received += 1; total += x; if (div == received) parent ! total
  }

  private def mkChild(n: Int): ActorRef = context.system.actorOf(Props(classOf[Skynet], self, num + n * (size / div), size / div, div))
}

class Root extends Actor {

  val startTime = System.currentTimeMillis()
  context.system.actorOf(Props(classOf[Skynet], self, 0, 1000000, 10))

  override def receive = {
    case x: Long =>
      val diffMs = System.currentTimeMillis() - startTime
      println(s"Result: $x in $diffMs ms.")
  }
}

object Root extends App {
  ActorSystem.create("main").actorOf(Props[Root])
}
