(*
 * Copyright (C) 2016 David Scott <dave@recoil.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *)

let project_url = "http://github.com/djs55/ocaml-dns-forward"

open Cmdliner

(* Help sections common to all commands *)

let _common_options = "COMMON OPTIONS"
let help = [
 `S _common_options;
 `P "These options are common to all commands.";
 `S "MORE HELP";
 `P "Use `$(mname) $(i,COMMAND) --help' for help on a single command."; `Noblank;
 `S "BUGS"; `P (Printf.sprintf "Check bug reports at %s" project_url);
]

(* Options common to all commands *)
let common_options_t =
  let docs = _common_options in
  let debug =
    let doc = "Give only debug output." in
    Arg.(value & flag & info ["debug"] ~docs ~doc) in
  Term.(pure Common.make $ debug)

let port =
  let doc = "Local port to serve DNS queries on" in
  Arg.(value & opt int 5555 & info [ "port" ] ~doc)

let config =
  let doc = "Path of configuration file" in
  Arg.(value & pos 0 file "" & info [] ~doc)

let serve_cmd =
  let doc = "Listen for DNS requests and forward them" in
  let man = [
    `S "DESCRIPTION";
    `P "Listen for DNS requests on a local port and forward them to an upstream\
        server."
  ] @ help in
  Term.(ret(pure Impl.serve $ port $ config)),
  Term.info "serve" ~sdocs:_common_options ~doc ~man

let _ =
  Logs.set_reporter (Logs_fmt.reporter ());
  match Term.eval serve_cmd with
  | `Error _ -> exit 1
  | _ -> exit 0
