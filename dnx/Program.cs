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
            Stopwatch sw = new Stopwatch();
            long limit = 1000000;

            sw.Start();
            var x = skynet(0, limit, 10, false);
            x.Wait();
            sw.Stop();

            Console.WriteLine(x.Result);
            Console.WriteLine("Sync sec: {0:0.000}", sw.ElapsedMilliseconds / 1000.0f);

            sw.Restart();
            var x2 = skynet(0, limit, 10, true);
            x2.Wait();
            sw.Stop();
            
            Console.WriteLine(x2.Result);
            Console.WriteLine("Async sec: {0:0.000}", sw.ElapsedMilliseconds / 1000.0f);
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
