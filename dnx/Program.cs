using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading.Tasks;


namespace ActorBenchmark
{
    class Program
    {
        static void Main(string[] args)
        {
            long limit = 1000000;
            DateTime dt = DateTime.Now;
            var x = skynetSync(0, limit, 10);
            Console.WriteLine(x);
            DateTime dt2 = DateTime.Now;
            Console.WriteLine("Sync sec: {0:0.000}", (dt2 - dt).TotalSeconds);
            var x2 = Task.Run(() => skynetAsync(0, limit, 10));
            x2.Wait();
            DateTime dt3 = DateTime.Now;
            Console.WriteLine(x2.Result);
            Console.WriteLine("Async sec: {0:0.000}", (dt3 - dt2).TotalSeconds);
            //Console.ReadLine();
        }
        static object taskLock = new object();

        private static long skynetSync(long num, long size, long div)
        {
            if (size == 1)
            {
                return num;
            }
            else
            {
                long sum = 0;
                var tasks = new List<Task<long>>();
                for (var i = 0; i < div; i++)
                {
                    var sub_num = num + i * (size / div);
                    sum += skynetSync(sub_num, size / div, div);
                }
                return sum;
            }
        }

        private static Task<long> skynetAsync(long num, long size, long div)
        {
            if (size == 1)
            {
                return Task.FromResult(num);
            }
            else
            {                               
                var tasks = new List<Task<long>>();
                for (var i = 0; i < div; i++)
                {
                    var sub_num = num + i * (size / div);
                    var task = Task.Run(() => skynetAsync(sub_num, size / div, div));
                    tasks.Add(task);
                }
                return Task.WhenAll(tasks).ContinueWith(skynetAggregator);
            }
        }

        static long skynetAggregator(Task<long[]> children)
        {
            long sumAsync = 0;
            foreach (var x in children.Result)
            {
                sumAsync += x;
            }
            return sumAsync;
        }
    }
}
