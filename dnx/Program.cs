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
            var x = skynet(0, limit, 10, false);
            x.Wait();
            Console.WriteLine(x.Result);
            DateTime dt2 = DateTime.Now;
            Console.WriteLine("Sync sec: {0:0.000}", (dt2 - dt).TotalSeconds);
            var x2 = skynet(0, limit, 10, true);
            DateTime dt3 = DateTime.Now;
            Console.WriteLine(x.Result);
            Console.WriteLine("Sync sec: {0:0.000}", (dt3 - dt2).TotalSeconds);
            //Console.ReadLine();
        }
        static object taskLock = new object();

        static Task<long> skynet(long num, long size, long div, bool async)
        {
            if (size == 1)
            {
                return Task.FromResult(num);
            }
            else
            {
                long sum = 0;
                var tasks = new List<Task<long>>();
                for (var i = 0; i < div; i++)
                {
                    var sub_num = num + i * (size / div);
                    if (!async)
                    {
                        sum += skynet(sub_num, size / div, div, false).Result;
                    }
                    else
                    {
                        var task = skynet(sub_num, size / div, div, true);
                        tasks.Add(task);
                    }
                }
                if (!async)
                {
                    return Task.FromResult(sum);
                }
                else
                {
                    return Task.WhenAll(tasks).ContinueWith(skynetAggregator);
                }
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
