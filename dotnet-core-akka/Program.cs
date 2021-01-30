using System;
using Akka.Actor;

namespace SkynetAkka
{
    class Run
    {
        public int Num;

        public Run(int num)
        {
            Num = num;
        }
    }

    class Start
    {
        public int Level;
        public long Num;

        public Start(int level, long num)
        {
            Level = level;
            Num = num;
        }
    }

    class Skynet : UntypedActor
    {
        public static Props Props() => Akka.Actor.Props.Create(() => new Skynet());

        private int _todo = 10;
        private long _count;

        protected override void OnReceive(object message)
        {
            switch (message)
            {
                case Start obj:
                    if (obj.Level == 1)
                    {
                        Context.Parent.Tell(obj.Num);
                        Context.Stop(Self);
                    }
                    else
                    {
                        var start = obj.Num * 10;
                        for (var i = 0; i <= 9; i++)
                        {
                            Context.ActorOf(Props()).Tell(new Start(obj.Level - 1, start + i));
                        }
                    }
                    break;
                case long l:
                    _todo -= 1;
                    _count += l;
                    if (_todo == 0)
                    {
                        Context.Parent.Tell(_count);
                        Context.Stop(Self);
                    }
                    break;
            }
        }
    }

    class Root : UntypedActor
    {
        public static Props Props() => Akka.Actor.Props.Create(() => new Root());

        protected override void OnReceive(object message)
        {
            switch (message)
            {
                case Run obj:
                    StartRun(obj.Num);
                    break;
            }
        }

        private void StartRun(int n)
        {
            var start = DateTime.Now.Ticks;
            var skynetActor = Context.ActorOf(Skynet.Props());
            skynetActor.Tell(new Start(7, 0));
            Context.Become(Waiting(n - 1, start));
        }

        private UntypedReceive Waiting(int n, long start)
        {
            return msg =>
            {
                switch (msg)
                {
                    case long x:
                        var diffMs = TimeSpan.FromTicks(DateTime.Now.Ticks - start).Milliseconds;

                        Console.WriteLine($"Result: {x} in {diffMs} ms.");

                        if (n == 0) Context.System.Terminate();
                        else StartRun(n);

                        break;
                }
            };
        }
    }

    class Program
    {
        static void Main()
        {
            var root = ActorSystem.Create("main").ActorOf(Root.Props());
            root.Tell(new Run(3));
            Console.Read();
        }
    }
}
