UNCHANGED:=ocaml-4.14-unchanged
VERIFIED:=ocaml-4.14-verified-gc
BDWGC:=ocaml-4.14-bdwgc
unchanged:
	PWD=$(shell pwd)
	cd $(UNCHANGED); ./configure --prefix=$(PWD)/$(UNCHANGED)/_install  --disable-naked-pointers
	make -C $(UNCHANGED) -j
	make -C $(UNCHANGED) install

verified-gc:
	cd $(VERIFIED); ./configure --disable-naked-pointers
	make -C $(VERIFIED)/runtime -j ocamlrun ocamlrund

bdwgc:
	cd $(BDWGC); ./configure --disable-naked-pointers
	make -C $(BDWGC)/runtime -j ocamlrun ocamlrund

verified-gc-opt:
	cd $(UNCHANGED) && ./configure --prefix=`pwd`/BUILD --disable-naked-pointers
	cd $(VERIFIED) && ./configure --disable-naked-pointers
	cd $(VERIFIED)/runtime && make -j libasmrun.a
	mkdir -p vergc_opt
	cp $(VERIFIED)/runtime/libasmrun.a vergc_opt/
	cp $(VERIFIED)/runtime/libasmrun.a $(UNCHANGED)/runtime/
	cd $(UNCHANGED) && make -j core
	cd $(UNCHANGED) && make -j ocamlopt.vergc
	cp $(UNCHANGED)/ocamlopt.vergc vergc_opt/
	cd $(UNCHANGED)/stdlib && make -j all std_exit.cmx stdlib.cma stdlib.cmxa
	mkdir -p $(UNCHANGED)/BUILD/lib/ocaml/
	cd $(UNCHANGED)/stdlib && make install installopt installopt-default
	cd $(UNCHANGED) && make -j || true
	cd $(UNCHANGED) && make install || true

clean-unchanged:
	make -C $(UNCHANGED) distclean

clean-bdwgc:
	make -C $(BDWGC) distclean

clean-verified-gc:
	make -C $(VERIFIED) distclean

clean-verified-gc-opt:
	make -C $(VERIFIED)/runtime clean
	make -C $(UNCHANGED) distclean
	rm -f $(UNCHANGED)/ocamlopt.vergc
	rm -rf vergc_opt/libasmrun.a vergc_opt/ocamlopt.vergc

all: unchanged verified-gc bdwgc

clean-all: clean-unchanged clean-verified-gc clean-bdwgc clean-verified-gc-opt
