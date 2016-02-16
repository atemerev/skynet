// Learn more about F# at http://fsharp.net
// See the 'F# Tutorial' project for more help.

open System.Diagnostics

type State = { remaining: int64; aggregate: int64 }

let div = 10L

let rec launch num size postback =
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
      launch subNum subSize mbp.Post

let sw = Stopwatch.StartNew()
launch 0L 1000000L (printfn "Value = %d")

[<EntryPoint>]
let main argv = 
    printfn "%A" argv
    printfn "Time = %d" sw.ElapsedMilliseconds
    0 // return an integer exit code

