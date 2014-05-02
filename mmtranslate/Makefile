mmtranslate.exe: ohelper.ml
	ocamlfind ocamlopt -linkpkg -package str -o $@ ohelper.ml

install: mmtranslate.exe
	cp $< /cygdrive/c/ocamlmgw/bin

.PHONY: clean install

clean:
	rm -f *.cm* *.o *.exe


