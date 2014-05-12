open Std_internal

module Make_sexp_deserialization_test (T : Stable_unit_test_intf.Arg) = struct
  TEST_UNIT "sexp deserialization" =
    List.iter T.tests
      ~f:(fun (t, sexp_as_string, _) ->
        let sexp = Sexp.of_string sexp_as_string in
        let t' = T.t_of_sexp sexp in
        if not (T.equal t t') then
          failwiths "sexp deserialization mismatch" (`Expected t, `But_got t')
            (<:sexp_of< [ `Expected of T.t ] * [ `But_got of T.t ] >>)
      )
end

module Make_sexp_serialization_test (T : Stable_unit_test_intf.Arg) = struct
  TEST_UNIT "sexp serialization" =
    List.iter T.tests
      ~f:(fun (t, sexp_as_string, _) ->
        let sexp = Sexp.of_string sexp_as_string in
        let serialized_sexp = T.sexp_of_t t in
        if serialized_sexp <> sexp then
          failwiths "sexp serialization mismatch"
            (`Expected sexp, `But_got serialized_sexp)
            (<:sexp_of< [ `Expected of Sexp.t ] * [ `But_got of Sexp.t ] >>);
      )
end

module Make_bin_io_test (T : Stable_unit_test_intf.Arg) = struct
  TEST_UNIT "bin_io" =
    List.iter T.tests
      ~f:(fun (t, _, expected_bin_io) ->
        let binable_m = (module T : Binable.S with type t = T.t) in
        let to_bin_string t = Binable.to_string binable_m t in
        let serialized_bin_io = to_bin_string t in
        if serialized_bin_io <> expected_bin_io then
          failwiths "bin_io serialization mismatch"
            (t, `Expected expected_bin_io, `But_got serialized_bin_io)
            (<:sexp_of< T.t * [ `Expected of string ] * [ `But_got of string ] >>);
        let t' = Binable.of_string binable_m serialized_bin_io in
        if not (T.equal t t') then
          failwiths "bin_io deserialization mismatch" (`Expected t, `But_got t')
            (<:sexp_of< [ `Expected of T.t ] * [ `But_got of T.t ] >>);
      )
end

module Make (T : Stable_unit_test_intf.Arg) = struct
  include Make_sexp_deserialization_test (T)
  include Make_sexp_serialization_test (T)
  include Make_bin_io_test (T)
end

module Make_unordered_container (T : Stable_unit_test_intf.Unordered_container_arg) =
struct
  module Test = Stable_unit_test_intf.Unordered_container_test

  TEST_UNIT "sexp" =
    List.iter T.tests
      ~f:(fun (t, {Test. sexps; _ }) ->
        let sexps = List.map sexps ~f:Sexp.of_string in
        let serialized_elements =
          match T.sexp_of_t t with
          | Sexp.List sexps -> sexps
          | Sexp.Atom _ ->
            failwiths "expected list when serializing unordered container"
              t T.sexp_of_t
        in
        let sorted_sexps = List.sort ~cmp:compare sexps in
        let sorted_serialized = List.sort ~cmp:compare serialized_elements in
        if not (List.equal ~equal:(=) sorted_sexps sorted_serialized) then
          failwiths "sexp serialization mismatch"
            (`Expected sexps, `But_got serialized_elements)
            <:sexp_of< [ `Expected of Sexp.t list ] * [ `But_got of Sexp.t list ] >>;
        let sexp_permutations = List.init 10 ~f:(fun _ -> List.permute sexps) in
        List.iter sexp_permutations ~f:(fun sexps ->
          let t' = T.t_of_sexp (Sexp.List sexps) in
          if not (T.equal t t') then
            failwiths "sexp deserialization msimatch"
              (`Expected t, `But_got t')
              <:sexp_of< [ `Expected of T.t ] * [ `But_got of T.t ] >>);
      )
  ;;

  let rec is_concatenation string strings =
    if String.is_empty string then
      List.for_all strings ~f:String.is_empty
    else
      let rec loop rev_skipped strings =
        match strings with
        | [] -> false
        | prefix :: strings ->
          let continue () = loop (prefix :: rev_skipped) strings in
          match String.chop_prefix ~prefix string with
          | None -> continue ()
          | Some string ->
            is_concatenation string (List.rev_append rev_skipped strings)
            || continue ()
      in
      loop [] strings
  ;;

  TEST_UNIT "bin_io" =
    List.iter T.tests
      ~f:(fun (t, {Test. bin_io_header; bin_io_elements; _ }) ->
        let binable_m = (module T : Binable.S with type t = T.t) in
        let elements = bin_io_elements in
        let bin_io_of_elements elements = bin_io_header ^ String.concat elements in
        let serialized = Binable.to_string binable_m t in
        let serialization_matches =
          match String.chop_prefix ~prefix:bin_io_header serialized with
          | None -> false
          | Some elements_string -> is_concatenation elements_string elements
        in
        if not serialization_matches then
          failwiths "serialization mismatch"
            (`Expected (bin_io_header, elements), `But_got serialized)
            <:sexp_of< [`Expected of (string * string list)] * [`But_got of string] >>;
        let permutatations = List.init 10 ~f:(fun _ -> List.permute elements) in
        List.iter permutatations ~f:(fun elements ->
          let t' = Binable.of_string binable_m (bin_io_of_elements elements) in
          if not (T.equal t t') then
            failwiths "bin-io deserialization mismatch"
              (`Expected t, `But_got t')
              <:sexp_of< [ `Expected of T.t ] * [ `But_got of T.t ] >>);
      )
  ;;
end