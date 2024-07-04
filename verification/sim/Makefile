.PHONY: all
all: 
	@echo "What are you expecting? (￣ー￣)";
	@echo "Read the makefile.";

.PHONY: air
air:
	python3 ./main.py --sim questa --test tb_air --top  cv32e40p_tb_subsystem --waves true

.PHONY: air_icarus
air_icarus:
	python3 ./main.py --sim icarus --test tb_air --top  cv32e40p_tb_subsystem --waves true

.PHONY: clean
clean:
	@echo "Cleaning sim outputs";
	-rm -rf ./sim_build
