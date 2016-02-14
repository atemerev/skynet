using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using System.Threading.Tasks.Dataflow;

namespace MicroTestM
{
	class Program
	{
		static void Main( string[] args )
		{
			long limit = 1000000;

			Stopwatch  sw = Stopwatch.StartNew();
			var x = skynetSync( 0, limit, 10 );
			Console.WriteLine( x );
			Console.WriteLine( "Sync sec: {0:0.000}", sw.Elapsed.TotalSeconds );

			sw.Restart();
			var x2 = Task.Run( () => skynetAsync( 0, limit, 10 ) );
			x2.Wait();
			Console.WriteLine( x2.Result );
			Console.WriteLine( "Async sec: {0:0.000}", sw.Elapsed.TotalSeconds );

			sw.Restart();
			var x3 = Task.Run( () => skynetTpl( 0, limit, 10 ) );
			x3.Wait();
			Console.WriteLine( x3.Result );
			Console.WriteLine( "TPL sec: {0:0.000}", sw.Elapsed.TotalSeconds );

			// Console.ReadLine();
		}
		static object taskLock = new object();

		private static long skynetSync( long num, long size, long div )
		{
			if( size == 1 )
			{
				return num;
			}
			else
			{
				long sum = 0;
				var tasks = new List<Task<long>>();
				for( var i = 0; i < div; i++ )
				{
					var sub_num = num + i * (size / div);
					sum += skynetSync( sub_num, size / div, div );
				}
				return sum;
			}
		}

		static Task<long> skynetAsync( long num, long size, long div )
		{
			if( size == 1 )
				return Task.FromResult( num );

			var tasks = new List<Task<long>>();
			for( var i = 0; i < div; i++ )
			{
				var sub_num = num + i * (size / div);
				var task = Task.Run(() => skynetAsync(sub_num, size / div, div));
				tasks.Add( task );
			}
			return Task.WhenAll( tasks ).ContinueWith( skynetAggregator );
		}

		static long skynetAggregator( Task<long[]> children )
		{
			long sumAsync = 0;
			foreach( var x in children.Result )
			{
				sumAsync += x;
			}
			return sumAsync;
		}

		static void skynetTplRecursion( ITargetBlock<long> src, long num, long size, long div )
		{
			if( size == 1 )
			{
				src.SendAsync( num );
				return;
			}

			for( var i = 0; i < div; i++ )
			{
				var sub_num = num + i * ( size / div );
				skynetTplRecursion( src, sub_num, size / div, div );
			}
		}

		static async Task<long> skynetTpl( long num, long size, long div )
		{
			BatchBlock<long> source = new BatchBlock<long>( 1024 );

			long sum = 0;
			ActionBlock<long[]> actAggregate = new ActionBlock<long[]>( vals => sum += vals.Sum(),
				new ExecutionDataflowBlockOptions() { MaxDegreeOfParallelism = 1, SingleProducerConstrained = true } );

			source.LinkTo( actAggregate, new DataflowLinkOptions() { PropagateCompletion = true } );

			skynetTplRecursion( source, num, size, div );
			source.Complete();

			await actAggregate.Completion;

			return sum;
		}
	}
}