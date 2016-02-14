open System
open System.Diagnostics

type State = { remaining: int64; aggregate: int64 }

[<EntryPoint>]
let main _ = 
  let sw = Stopwatch()
  let div = 10L

  let rec launch postback num size =
    if size = 1L then
      postback num
    else
      let mbp = MailboxProcessor<_>.Start(fun inbox ->
        let rec loop state =
          async {
            let! value = inbox.Receive()
            if state.remaining = 1L then
              postback (state.aggregate + value)
            else
              return! loop { remaining = state.remaining - 1L; aggregate = state.aggregate + value }
          }
        loop { remaining = div; aggregate = 0L })
      for i = 0 to 9 do
        let subSize = size / div
        let subNum = num + (int64 i) * subSize
        launch mbp.Post subNum subSize

  let print value = printfn "Value = %d\r\nTime = %d ms" value sw.ElapsedMilliseconds

  sw.Start()
  launch print 0L 1000000L
  Console.ReadLine() |> ignore
  0