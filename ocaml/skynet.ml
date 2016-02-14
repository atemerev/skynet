(* To compile:
   ocamlfind opt -package lwt.unix -linkpkg skynet.ml -o skynet
   With trunk+flambda ocaml:
   ocamlfind opt -O3 -package lwt.unix -linkpkg skynet.ml -o skynet
*)

(** Lwt version *)
let return = Lwt.return
let print = Lwt_io.printf
let run = Lwt_main.run
let (>>=) = Lwt.bind

(** Direct version. *)
(* let return x = x *)
(* let print = Printf.printf *)
(* let run x = x *)
(* let (>>=) = (|>) *)


let div = 10

(* Launch ten subtasks *)
let rec iter ~size ~num i res =
  if i = 10
  then return res
  else
    (* Launch the subtask of the give num/size and pass the result
       to the following iteration *)
    launch ~size ~num res >>=
    iter ~size ~num:(num + size) (i+1)

(* Launch a task *)
and launch ~size ~num res =
  if size = 1 then
    (* If the size is one, we add the number and the tasks
       returns immediately. *)
    return (num+res)
  else
    (* Otherwise, We launch subtasks. *)
    let size = size / div in
    iter ~size ~num 0 res

let main =
  (* We keep sequentiality for timing with >>=. *)
  let time = Unix.gettimeofday () in
  launch ~size:1000000 ~num:0 0 >>=
  print "Value = %i\n" >>= fun () ->
  print "Time = %fs\n" (Unix.gettimeofday () -. time)


let () =
  (* FIRE *)
  run main
