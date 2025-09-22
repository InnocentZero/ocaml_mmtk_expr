let rec tail = function [] -> None | [ t ] -> Some t | _ :: t -> tail t

let rec last_two = function
  | [] | [ _ ] -> None
  | [ e1; e2 ] -> Some (e1, e2)
  | _ :: t -> last_two t

let rec at x = function
  | [] -> None
  | h :: t -> if x = 0 then Some h else at (x - 1) t

let len lst = List.fold_left (fun acc _ -> acc + 1) 0 lst
let rev lst = List.fold_left (fun acc x -> x :: acc) [] lst
let is_palindrome lst = lst = rev lst

type 'a node = One of 'a | Many of 'a node list

let rec flatten = function
  | [] -> []
  | h :: t -> (
      match h with One a -> a :: flatten t | Many l -> flatten l @ flatten t)

let flatten_tailrec =
  let rec flat_aux ?(continuation = fun x -> x) = function
    | [] -> continuation []
    | One e :: t ->
        flat_aux ~continuation:(fun tail -> e :: tail |> continuation) t
    | Many l :: t ->
        let inner_continuation rtail ltail = ltail @ rtail |> continuation in
        let outer_continuation rtail =
          flat_aux l ~continuation:(inner_continuation rtail)
        in
        flat_aux ~continuation:outer_continuation t
  in
  flat_aux

let head_matches elem lst =
  match (lst, elem) with [], _ -> false | h :: _, h' -> h' = h

let eliminate_dups lst =
  List.fold_left
    (fun acc elem -> if head_matches elem acc then acc else elem :: acc)
    [] lst
  |> List.rev

let pack lst =
  let consolidate acc elem =
    match (acc, elem) with
    | [], elem -> [ [ elem ] ]
    | (h :: _ as first) :: rest, elem when elem = h -> (elem :: first) :: rest
    | acc, elem -> [ elem ] :: acc
  in
  List.fold_left consolidate [] lst |> List.rev

let rle lst =
  let fold acc elem =
    match acc with
    | [] -> [ (1, elem) ]
    | (cnt, h) :: t when h = elem -> (cnt + 1, h) :: t
    | acc -> (1, elem) :: acc
  in
  List.fold_left fold [] lst |> List.rev

type 'a rle_ = One of 'a | Many of int * 'a

let mrle lst =
  let fold acc elem =
    match acc with
    | [] -> [ One elem ]
    | One h :: t when h = elem -> Many (2, h) :: t
    | Many (n, h) :: t when h = elem -> Many (n + 1, h) :: t
    | acc -> One elem :: acc
  in
  List.fold_left fold [] lst |> List.rev

let decode_rle lst =
  let rec repeat elem cnt acc =
    if cnt = 0 then acc else repeat elem (cnt - 1) (elem :: acc)
  in
  let fold acc elem =
    match elem with
    | One elem -> elem :: acc
    | Many (n, elem) -> repeat elem n [] @ acc
  in
  List.fold_left fold [] lst |> List.rev

let duplicate lst =
  List.fold_left (fun acc elem -> elem :: elem :: acc) [] lst |> List.rev

let replicate lst n =
  let rec repeat elem cnt acc =
    if cnt = 0 then acc else repeat elem (cnt - 1) (elem :: acc)
  in
  List.fold_left (fun acc x -> acc @ repeat x n []) [] lst

let drop_nth lst n =
  let reversed, _ =
    List.fold_left
      (fun (acc, ind) elem ->
        if ind = 1 then (acc, n) else (elem :: acc, ind - 1))
      ([], n) lst
  in
  List.rev reversed

let split lst cnt =
  let split_fold (prefix, suffix, ind) elem =
    if ind = 0 then (prefix, elem :: suffix, 0)
    else (elem :: prefix, suffix, ind - 1)
  in
  let prefix, suffix, _ = List.fold_left split_fold ([], [], cnt) lst in
  (List.rev prefix, List.rev suffix)

let slice lst ind1 ind2 =
  let prefix, _ = split lst (ind2 + 1) in
  let _, actual = split prefix ind1 in
  actual

let rotate lst n =
  let prefix, suffix = split lst n in
  suffix @ prefix

let remove_at lst ind =
  match split lst ind with prefix, _ :: t -> prefix @ t | prefix, [] -> prefix

let insert_at elem ind lst =
  match split lst ind with prefix, suffix -> prefix @ (elem :: suffix)

let range start end_ind =
  let rec range_aux start end_ind acc =
    if start > end_ind then rev acc
    else range_aux (start + 1) end_ind (start :: acc)
  in
  range_aux start end_ind []

let extract =
  let rec extract k lst ~continuation =
    if k <= 0 then continuation [ [] ]
    else
      match lst with
      | [] -> continuation []
      | h :: tl ->
          let inner_continuation with_head without_head =
            with_head @ without_head |> continuation
          in
          let outer_continuation lst =
            extract k tl ~continuation:(inner_continuation lst)
          in
          let map_continuation lst =
            List.map (fun l -> h :: l) lst |> outer_continuation
          in
          extract (k - 1) tl ~continuation:map_continuation
  in
  extract ~continuation:(fun x -> x)

(* let group lst ind1 ind2 = *)
(*   let cumulative = ind1 + ind2 in *)
(*   let initial_groups = extract cumulative lst in *)
(*   let first_grouping = List.map (extract ind1) initial_groups in *)
(*   let second_grouping = List.map (extract ind2) initial_groups in *)
(*   let cartesian_product =  *)
(*   let contains lst elem = *)
(*     List.fold_left (fun present e -> present || elem = e) false lst *)
(*   in *)
(*   let null_intersection lst1 lst2 = *)
(*     List.fold_left *)
(*       (fun intersects elem -> intersects || contains lst1 elem) *)
(*       false lst2 *)
(*   in *)
(*   List.fold_left *)
(*     (fun acc group -> (extract ind1 group @ extract ind2 group) :: acc) *)
(*     [] initial_groups *)

let () =
  print_endline "Beginners, run `dune runtest` to execute tests";
  assert (tail [] = None);
  assert (tail [ 3; 4 ] = Some 4);
  assert (last_two [] = None);
  assert (last_two [ 1 ] = None);
  assert (last_two [ 3; 5; 6 ] = Some (5, 6));
  assert (at 2 [] = None);
  assert (at 3 [ 1; 2 ] = None);
  assert (at 1 [ 1; 3; 4 ] = Some 3);
  assert (len [] = 0);
  assert (len [ 3; 4; 5 ] = 3);
  assert (rev [] = []);
  assert (rev [ 1; 2; 3; 4 ] = [ 4; 3; 2; 1 ]);
  assert (is_palindrome []);
  assert (is_palindrome [ 1 ]);
  assert (is_palindrome [ 1; 2; 1 ]);
  assert (is_palindrome [ 1; 2; 3; 3; 2; 1 ]);
  assert (
    flatten [ One "a"; Many [ One "b"; Many [ One "c"; One "d" ]; One "e" ] ]
    = [ "a"; "b"; "c"; "d"; "e" ]);
  assert (
    flatten_tailrec
      [ One "a"; Many [ One "b"; Many [ One "c"; One "d" ]; One "e" ] ]
    = [ "a"; "b"; "c"; "d"; "e" ]);
  assert (
    eliminate_dups
      [ "a"; "a"; "a"; "a"; "b"; "c"; "c"; "a"; "a"; "d"; "e"; "e"; "e"; "e" ]
    = [ "a"; "b"; "c"; "a"; "d"; "e" ]);
  assert (
    pack
      [
        "a";
        "a";
        "a";
        "a";
        "b";
        "c";
        "c";
        "a";
        "a";
        "d";
        "d";
        "e";
        "e";
        "e";
        "e";
      ]
    = [
        [ "a"; "a"; "a"; "a" ];
        [ "b" ];
        [ "c"; "c" ];
        [ "a"; "a" ];
        [ "d"; "d" ];
        [ "e"; "e"; "e"; "e" ];
      ]);
  assert (
    rle [ "a"; "a"; "a"; "a"; "b"; "c"; "c"; "a"; "a"; "d"; "e"; "e"; "e"; "e" ]
    = [ (4, "a"); (1, "b"); (2, "c"); (2, "a"); (1, "d"); (4, "e") ]);
  assert (
    mrle
      [ "a"; "a"; "a"; "a"; "b"; "c"; "c"; "a"; "a"; "d"; "e"; "e"; "e"; "e" ]
    = [
        Many (4, "a");
        One "b";
        Many (2, "c");
        Many (2, "a");
        One "d";
        Many (4, "e");
      ]);
  assert (
    decode_rle
      [
        Many (4, "a");
        One "b";
        Many (2, "c");
        Many (2, "a");
        One "d";
        Many (4, "e");
      ]
    = [ "a"; "a"; "a"; "a"; "b"; "c"; "c"; "a"; "a"; "d"; "e"; "e"; "e"; "e" ]);
  assert (
    duplicate [ "a"; "b"; "c"; "c"; "d" ]
    = [ "a"; "a"; "b"; "b"; "c"; "c"; "c"; "c"; "d"; "d" ]);
  assert (
    replicate [ "a"; "b"; "c" ] 3
    = [ "a"; "a"; "a"; "b"; "b"; "b"; "c"; "c"; "c" ]);
  assert (
    drop_nth [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i"; "j" ] 3
    = [ "a"; "b"; "d"; "e"; "g"; "h"; "j" ]);
  assert (
    split [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i"; "j" ] 3
    = ([ "a"; "b"; "c" ], [ "d"; "e"; "f"; "g"; "h"; "i"; "j" ]));
  assert (split [ "a"; "b"; "c"; "d" ] 5 = ([ "a"; "b"; "c"; "d" ], []));
  assert (
    slice [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h"; "i"; "j" ] 2 6
    = [ "c"; "d"; "e"; "f"; "g" ]);
  assert (slice [] 1 2 = []);
  assert (slice [] 2 1 = []);
  assert (slice [] 4 4 = []);
  assert (slice [ "a"; "b"; "c"; "d" ] 3 3 = [ "d" ]);
  assert (slice [ "a"; "b" ] 1 2 = [ "b" ]);
  assert (slice [ "a"; "b" ] 3 5 = []);
  assert (slice [ "a"; "b" ] 1 0 = []);
  assert (
    rotate [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h" ] 3
    = [ "d"; "e"; "f"; "g"; "h"; "a"; "b"; "c" ]);
  assert (
    rotate [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h" ] 10
    = [ "a"; "b"; "c"; "d"; "e"; "f"; "g"; "h" ]);
  assert (remove_at [ "a"; "b"; "c"; "d" ] 1 = [ "a"; "c"; "d" ]);
  assert (remove_at [ "a"; "b" ] 3 = [ "a"; "b" ]);
  assert (
    insert_at "alfa" 1 [ "a"; "b"; "c"; "d" ] = [ "a"; "alfa"; "b"; "c"; "d" ]);
  assert (range 4 9 = [ 4; 5; 6; 7; 8; 9 ]);
  assert (
    extract 2 [ "a"; "b"; "c"; "d" ]
    = [
        [ "a"; "b" ];
        [ "a"; "c" ];
        [ "a"; "d" ];
        [ "b"; "c" ];
        [ "b"; "d" ];
        [ "c"; "d" ];
      ])
