using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;


namespace ActorBenchmark
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine($"Arch {(IntPtr.Size == 8 ? "64 bit" : "32 bit")}");

            var runs = 3;
            for (var i = 0; i < runs; i++)
            {
                Run(i == runs - 1);
            }
        }

        private static void Run(bool output)
        {
            long limit = 1000000;
            var sw = Stopwatch.StartNew();

            sw.Restart();
            var x = skynetSync(0, limit, 10);
            sw.Stop();
            var t1 = sw.Elapsed.TotalMilliseconds;

            if (output)
            {
                Console.WriteLine(x);
                Console.WriteLine($"1 Thread - Sync: {t1:0.000}ms");
            }
            CleanUp();

            sw.Restart();
            var x2 = skynetAsync(0, limit, 10).Result;
            sw.Stop();
            var t2 = sw.Elapsed.TotalMilliseconds;

            if (output)
            {
                Console.WriteLine(x2);
                Console.WriteLine($"1 Thread - Async: {t2:0.000}ms");
            }
            CleanUp();

            sw.Restart();
            var x3 = skynetThreadpoolAsync(0, limit, 10).Result;
            sw.Stop();
            var t3 = sw.Elapsed.TotalMilliseconds;

            if (output)
            {
                Console.WriteLine(x3);
                Console.WriteLine($"Parallel Async: {t3:0.000}ms");
            }
            CleanUp();

            sw.Restart();
            var x4 = skynetParallel(0, limit, 10);
            sw.Stop();
            var t4 = sw.Elapsed.TotalMilliseconds;

            if (output)
            {
                Console.WriteLine(x4);
                Console.WriteLine($"Parallel Sync: {t4:0.000}ms");
            }
            CleanUp();
        }

        private static long skynetSync(long num, long size, long div)
        {
            if (size == 1)
            {
                return num;
            }
            else
            {
                long sum = 0;
                for (var i = 0; i < div; i++)
                {
                    var sub_num = num + i * (size / div);
                    sum += skynetSync(sub_num, size / div, div);
                }
                return sum;
            }
        }

        private static Task<long> skynetThreadpoolAsync(long num, long size, long div)
        {
            if (size == 1)
            {
                return Task.FromResult(num);
            }
            else
            {
                var tasks = new List<Task<long>>((int)div);
                for (var i = 0; i < div; i++)
                {
                    var sub_num = num + i * (size / div);
                    var task = Task.Run(() => skynetAsync(sub_num, size / div, div));
                    tasks.Add(task);
                }
                return Task.WhenAll(tasks).ContinueWith(skynetAggregator);
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
                var tasks = new List<Task<long>>((int)div);
                for (var i = 0; i < div; i++)
                {
                    var sub_num = num + i * (size / div);
                    var task = skynetAsync(sub_num, size / div, div);
                    tasks.Add(task);
                }
                return Task.WhenAll(tasks).ContinueWith(skynetAggregator);
            }
        }

        static long skynetAggregator(Task<long[]> children)
        {
            long sumAsync = 0;
            var results = children.Result;
            for (var i = 0; i < results.Length; i++)
            {
                sumAsync += results[i];
            }
            return sumAsync;
        }

        private static long skynetParallel(long num, long size, long div)
        {
            if (size == 1)
            {
                return num;
            }
            else
            {
                long total = 0;

                long[] source = new long[div];
                for (var i = 0; i < div; i++)
                {
                    source[i] = i;
                }

                var rangePartitioner = Partitioner.Create(0L, source.Length);

                Parallel.ForEach(rangePartitioner,
                    () => 0L, 
                    (range, loopState, runningtotal) =>
                        {
                            for (long i = range.Item1; i < range.Item2; i++)
                            {
                                var sub_num = num + i * (size / div);
                                runningtotal += skynetSync(sub_num, size / div, div);
                            }
                            return runningtotal;
                        }, 
                    (subtotal) => Interlocked.Add(ref total, subtotal)
                );

                return total;
            }
        }

        static void CleanUp()
        {
            GC.Collect();
            GC.WaitForPendingFinalizers();
            GC.Collect();
        }
    }
}
