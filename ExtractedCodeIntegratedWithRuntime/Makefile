UNCHANGED:=ocaml-4.14-unchanged
VERIFIED:=ocaml-4.14-verified-gc
VERIFIEDOPT:=ocaml-4.14-verified-gc-opt
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
	PWD=$(shell pwd)
	cd $(VERIFIEDOPT); ./configure --prefix=$(PWD)/$(VERIFIEDOPT)/BUILD --disable-naked-pointers
	make -C $(VERIFIEDOPT) -j || true
	make -C $(VERIFIEDOPT) install || true

clean-unchanged:
	make -C $(UNCHANGED) clean

clean-bdwgc:
	make -C $(BDWGC) clean

clean-verified-gc:
	make -C $(VERIFIED) clean

clean-verified-gc-opt:
	make -C $(VERIFIEDOPT) clean

all: unchanged verified-gc bdwgc

clean-all: clean-unchanged clean-verified-gc clean-bdwgc clean-verified-gc-opt
