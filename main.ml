let grid_graph w h =
  let n = w * h in
  Array.init
    n
    (fun k ->
      let i = k / h in
      let j = k mod h in
      let res = ref [] in
      for a = 0 to w - 1 do
        for b = 0 to h - 1 do
          if i = a && (b = j + 1 || b = j - 1) || j = b && (a = i + 1 || a = i - 1)
          then
            res := (a*h + b) :: !res
        done;
      done;
      !res
    )

let graph = grid_graph 7 7

let n = int_of_string (input_line stdin)
let graph =
  Array.init
    n
    (fun _ ->
      List.map int_of_string (Str.split (Str.regexp " ") (input_line stdin))
    )

let update remaining graph index image new_remaining_indexes =  
  let new_remains = Array.map (fun list -> List.filter (fun x -> x <> image) list) remaining in
  if image = -1
  then
    new_remains.(index) <- []
  else
    begin 
      List.iter
        (fun neighbor ->
            new_remains.(neighbor) <- List.filter (fun x -> List.mem x graph.(image)) new_remains.(neighbor)
        ) graph.(index);
      List.iter
        (fun neighbor ->
          List.iter
            (fun i ->
              if List.mem neighbor graph.(i)
              then
                if not (List.mem i graph.(index))
                then
                  new_remains.(i) <- List.filter (fun x -> x <> neighbor) new_remains.(i)
            ) new_remaining_indexes
        ) graph.(image);
      new_remains.(index) <- [image]
    end;
  new_remains
                 
let find_translation ?(early_stop=max_int) graph =
  let best_translation = ref [||] in
  let best_score = ref max_int in
  let rec aux translation remaining_indexes remaining =
    let partial_loss = Array.fold_left (fun a b -> a + if b = [] then 1 else 0) 0 remaining in
    if partial_loss >= !best_score || partial_loss >= early_stop
    then
      ()
    else
      begin
        if remaining_indexes = []
        then
          begin            
            if partial_loss < !best_score
            then
              begin
                Printf.eprintf "Found translation with loss %5d\r%!" partial_loss;
                best_score := partial_loss;
                best_translation := Array.copy translation
              end;
          end
        else
          begin
            let explore = List.map (fun x -> (x,remaining.(x))) remaining_indexes in
            let explore = List.sort (fun (_,a) (_,b) -> compare (List.length a) (List.length b)) explore in
            let index = fst(List.hd explore) in
            let possibilities = Array.of_list remaining.(index) in
            let new_remaining_indexes = List.filter (fun x -> x <> index) remaining_indexes in
            for i = 0 to Array.length possibilities - 1 do
              translation.(index) <- possibilities.(i);
              aux translation new_remaining_indexes (update remaining graph index possibilities.(i) new_remaining_indexes)
            done;
            translation.(index) <- (-1);
            aux translation new_remaining_indexes (update remaining graph index (-1) new_remaining_indexes)
          end
      end
  in
  let t = Array.make (Array.length graph) (-1) in
  let r = Array.to_list (Array.init (Array.length graph) (fun i -> i)) in
  aux t r graph;
  !best_translation, !best_score

let _ =
  while Array.fold_left (fun a b -> a + if b <> [] then 1 else 0) 0 graph > 0 do
    let translation, score = find_translation graph in
    Printf.eprintf "Extracting maximal translation with loss %d\n%!" score;
    for i = 0 to Array.length graph - 1 do
      Printf.printf "%d " translation.(i)
    done;
    print_newline ();
    for i = 0 to Array.length graph - 1 do
      graph.(i) <- List.filter (fun x -> x <> translation.(i)) graph.(i)
    done;
  done
