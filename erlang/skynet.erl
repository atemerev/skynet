-module(skynet).
-export([skynet/4, skynet/2]).

skynet(Parent, Num, Size, Div) ->
  case Size of
    1 ->
      Parent ! Num;
    T when T > 1 ->
      NewSize = Size div Div,
      lists:foreach(fun(X) -> spawn(skynet, skynet, [self(), Num + X * NewSize, NewSize, Div]) end, lists:seq(0, Div - 1))
  end,
  process_sum(Parent, Div, 0, 0).

process_sum(Parent, Div, Received, Total) ->
  receive
    N ->
      case Received of
        X when X < Div - 1 -> process_sum(Parent, Div, Received + 1, Total + N);
        X -> Parent ! Total + N
      end
  end.

skynet(Size, Div) ->
  Start = erlang:system_time(milli_seconds),
  spawn(skynet, skynet, [self(), 0, Size, Div]),
  receive
    N ->
      End = erlang:system_time(milli_seconds),
      Diff = End - Start, 
      io:fwrite("Result: ~w in ~w ms.~n",[N, Diff])
  end.
