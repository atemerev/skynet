// Learn more about F# at http://fsharp.net
// See the 'F# Tutorial' project for more help.

open System.Diagnostics
let div = 10L

let rec launch num size postback =
  if size = 1L then
    postback num
  else
    let mbp = MailboxProcessor<_>.Start(fun inbox ->
      let rec loop remaining aggregate =
        async {
          let! value = inbox.Receive()
          if remaining = 1L then
            postback (aggregate + value)
          else
            return! loop (remaining - 1L) (aggregate + value)
        }
      loop div 0L )
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

