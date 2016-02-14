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
            Stopwatch sw = Stopwatch.StartNew();
            var x = skynet(0, limit, 10, false);
            Console.WriteLine(x);
            sw.Stop();
            Console.WriteLine("Sync sec: {0:0.000}", sw.ElapsedMilliseconds * 0.001);
            sw.Start();
            var x2 = skynet(0, limit, 10, true);
            Console.WriteLine(x);
            sw.Stop();
            Console.WriteLine("Async sec: {0:0.000}", sw.ElapsedMilliseconds * 0.001);
            //Console.ReadLine();
        }
        static long taskNum;
        static object taskLock = new object();

        static long skynet(long num, long size, long div, bool async)
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
                    if (!async)
                    {
                        sum += skynet(sub_num, size / div, div, false);
                    }
                    else
                    {
                        var task = Task.Factory.StartNew(() =>
                        {
                            //long ournum = 0;
                            //lock (taskLock)
                            //{
                            //    ournum = taskNum++;
                            //}                          
                            //Console.WriteLine("EXE {0}", ournum);
                            return skynet(sub_num, size / div, div, true);
                        });
                        tasks.Add(task);
                    }
                }
                if (async)
                {
                    Task.WaitAll(tasks.ToArray());
                    foreach (var t in tasks)
                    {
                        sum += t.Result;
                    }
                }
                return sum;
            }
        }
    }
}
