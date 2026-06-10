let rec tail lst = match lst with
  | [] -> None | [t] -> Some t | _ :: t -> tail t

let churn n =
  let acc = ref [] in
  for i = 0 to n do
    acc := [i;i+1] :: !acc;
    if i mod 1000 = 0 then acc := []
  done; List.length !acc

let () =
  let live = tail [1;2;3] in   (* Some 3 *)
  Printf.printf "BEFORE churn: live = Some %d? %b\n"
    (match live with Some x -> x | None -> -1)
    (live = Some 3);
  (* Churn just enough to fill the heap. 
     14541 is just below the full heap size, 
     as each churn cycles allocates 9 bytes on heap *)
  let _ = churn 14_542 in
  (match live with
   | Some x -> Printf.printf "AFTER churn: live = Some %d\n" x
   | None   -> Printf.printf "AFTER churn: live = None (CORRUPTED!)\n");
  Printf.printf "AFTER churn: (live = Some 3) = %b\n" (live = Some 3)
