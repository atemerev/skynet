#time "on"

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

launch 0L 1000000L (printfn "Value = %d")
