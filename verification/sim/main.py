import argparse
import os
from pathlib import Path

from cocotb.runner import get_runner

SCRIPT_DIR = Path(os.path.realpath(__file__)).parent.absolute()


def run_test(simulator: str, test_file: Path, top_module: str, waves: bool, cfile: str):
    hdl_dir = Path(SCRIPT_DIR / "../../rtl")
    sim_dir = Path(SCRIPT_DIR / "../../rtl/sim")
    verilog_files = hdl_dir.rglob("*.v")
    system_verilog_files = hdl_dir.rglob("*.sv")
    #mem_files = hdl_dir.rglob("*.mem")

    verilog_headers = hdl_dir.rglob("*.vh")
    system_verilog_headers = hdl_dir.rglob("*.svh")

    submodule_dir = Path(SCRIPT_DIR / "../../cv32e40p/rtl")
    submodule_verilog_files = submodule_dir.rglob("*.v")
    submodule_system_verilog_files = submodule_dir.rglob("*.sv")
    submodule_verilog_headers = submodule_dir.rglob("*.vh")
    submodule_system_verilog_headers = submodule_dir.rglob("*.svh")
    # submodule_include_dir = Path(SCRIPT_DIR / "../../cv32e40p/rtl/include")
    # submodule_include_files = submodule_dir.rglob("*.sv")

    #vivado_ip_verilog_dir = Path("/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims")
    #vivado_ip_verilog_files = vivado_ip_verilog_dir.rglob("*.v")
    #vivado_ip_verilog_files = list(vivado_ip_verilog_files)
    #vivado_ip_verilog_files.append("../../vivado/airsoc-dram-zc706/airsoc-dram-zc706.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_sim_netlist.v")
    #vivado_ip_verilog_files.append("/tools/Xilinx/Vivado/2022.2/data/verilog/src/glbl.v")
    vivado_ip_vhdls = ["/tools/Xilinx/Vivado/2022.2/data/vhdl/src/unisims/unisim_VCOMP.vhd", "/tools/Xilinx/Vivado/2022.2/data/vhdl/src/unisims/unisim_VPKG.vhd"]

    verilog_sources = (
        list(verilog_files)
        + list(system_verilog_files)
        + list(submodule_verilog_files)
        + list(submodule_system_verilog_files)
        #+ list(mem_files)
        + list(["../../vivado/airsoc-dram-zc706/airsoc-dram-zc706.gen/sources_1/ip/clk_wiz_1/clk_wiz_1_sim_netlist.v"])
        #+ list(["../../vivado/airsoc-dram-zc706/airsoc-dram-zc706.gen/sources_1/ip/clk_wiz_0/clk_wiz_0_sim_netlist.v"])
        #+ list(["/home/shc/projects/air-soc-dram/vivado/airsoc-dram-zc706/airsoc-dram-zc706.gen/sources_1/ip/clk_wiz_1/clk_wiz_1_sim_netlist.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/glbl.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/OBUFDS.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/IOBUFDS.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/OSERDESE2.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/ISERDESE2.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/IOBUF.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/IDELAYE2.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/IDELAYCTRL.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/BUFG.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/IBUFDS.v"])
        + list(["/tools/Xilinx/Vivado/2022.2/data/verilog/src/unisims/MMCME2_ADV.v"])
    )
    ## sort the sources to make sure that the def and pkg.sv files are at the beginning
    ## otherwise the simulator might not find the packages
    def_sv_paths = [path for path in verilog_sources if str(path).rsplit('/', 1)[-1].startswith("def")]
    pkg_sv_paths = [path for path in verilog_sources if str(path).endswith("pkg.sv")]
    other_paths = [path for path in verilog_sources if not str(path).rsplit('/', 1)[-1].startswith("def") and not str(path).endswith("pkg.sv")]
    verilog_sources = list(def_sv_paths) + list(pkg_sv_paths) + list(other_paths)

    include_dirs = [
        header.parent
        for header in list(verilog_headers)
        + list(system_verilog_headers)
        + list(submodule_verilog_headers)
        + list(submodule_system_verilog_headers)
    ]

    # subdirectories = [x[0] for x in os.walk(hdl_dir)]
    # include_dirs.extend(subdirectories)

    subdirectories = [x[0] for x in os.walk(submodule_dir)]
    include_dirs.extend(subdirectories)
    include_dirs.extend([sim_dir])
    #include_dirs.extend(mem_files)

    print("\nINCLUDE_DIRS:")
    print(include_dirs)
    print("\nVERILOG_SOURCES:")
    print(verilog_sources)

    import cocotb
    from cocotb.runner import Xcelium
    def fixed_test_command(self):
        self.env["CDS_AUTO_64BIT"] = "all"

        if self.pre_cmd:
            print("WARNING: pre_cmd is not implemented for Xcelium.")

        verbosity_opts = []
        if self.verbose:
            verbosity_opts += ["-messages", "-status", "-gverbose", "-pliverbose", "-plidebug", "-plierr_verbose"]
        else:
            verbosity_opts += ["-quiet", "-plinowarn"]

        tmpdir = f"implicit_tmpdir_{self.current_test_name}"
        xrun_top = ":" if self.hdl_toplevel_lang == "vhdl" else self.sim_hdl_toplevel

        input_script = (
            f"@database -open cocotb_waves -default;"
            f"probe -database cocotb_waves -create {xrun_top} -all -memories -variables -depth all;"
        #    f"probe -create -packed 131072 *;"
            f"run;"
            f"exit;"
            if self.waves
            else "@run; exit;"
        )

        cmds = [["mkdir", "-p", tmpdir]]
        cmds += [
            ["xrun"]
            + ["-logfile", f"xrun_{self.current_test_name}.log"]
            + ["-xmlibdirname", f"{self.build_dir}/xrun_snapshot"]
            + ["-cds_implicit_tmpdir", tmpdir]
            + ["-licqueue"]
            + verbosity_opts
            + ["-R"]
            + self.test_args
            + self.plusargs
            + (["-gui"] if self.gui else [])
            + ["-input", input_script]
        ]

        self.env["GPI_EXTRA"] = (
            cocotb.config.lib_name_path("vhpi", "xcelium") + ":cocotbvhpi_entry_point"
        )

        return cmds
    Xcelium._test_command = fixed_test_command

    runner_build_args = ["-modelsimini", "../../../vivado/modelsim.ini"]
    runner_pre_cmd = ['set WildcardFilter {};set WildcardSizeThreshold "16777216"; coverage save -onexit covres.ucdb;']
    runner_test_args = ["-suppress", "14408", "-suppress", "16154", "-suppress", "8630", "-modelsimini", "../../../vivado/modelsim.ini", "-L", "compiled-libs", "top.glbl"]

    if simulator.lower() == "xcelium":
        with open("pre_input.tcl", "w") as f:
            f.writelines(["set probe_packed_limit 0;\n", "set probe_unpacked_limit 0;\n"])
        if cfile.rsplit('/', 1)[-1].startswith("dram_demo"):
            runner_build_args.extend(["-f", "/tools/Xilinx/Vivado/2022.2/data/secureip/secureip_cell.list.f"])
        runner_build_args = [
                             #"-f", "/tools/Xilinx/Vivado/2022.2/data/secureip/secureip_cell.list.f",
                             "-newperf", "-plusperf",
                             "-top", "glbl", "-namemap_mixgen", "-verbose", "-access", "+rwc", "-timescale", "1ns/1ps", "-ALLOWREDEFINITION", "-relax", "-sv",
                             "-v93",
                             '+incdir+"../../../vivado/airsoc-dram-zc706/airsoc-dram-zc706.gen/sources_1/ip/clk_wiz_0"']
        if cfile.startswith("dram_demo"):
            runner_build_args.extend(["-f", "/tools/Xilinx/Vivado/2022.2/data/secureip/secureip_cell.list.f"])
        runner_pre_cmd = []
        runner_test_args = ["-newperf", "-plusperf", "-top", "glbl", "-verbose", "-access", "+rwc", "-timescale", "1ns/1ps", "-pre_input", "../pre_input.tcl"] #["set probe_packed_limit 131072; set probe_unpacked_limit 131072;"] #["probe -create -packed 131072 *;"]

    runner = get_runner(simulator)
    runner.build(
        verilog_sources=verilog_sources,
        vhdl_sources=vivado_ip_vhdls,
        includes=include_dirs,
        hdl_toplevel=top_module,
        always=True,
    #    build_args=["-L", "../../vivado/compiled-libs"]
    #    build_args=["-modelsimini", "../../../vivado/modelsim.ini"]
        build_args=runner_build_args
    )

    runner.test(
        hdl_toplevel=top_module,
    #    hdl_toplevel_library="glbl",
        hdl_toplevel_lang="verilog",
        test_module=str(test_file),
        waves=waves,
        gui=False,
        plusargs=["+nowarnTSCALE"],
        extra_env={
            "XILINX_VIVADO": "/tools/Xilinx/Vivado/2022.2",
        #    "COCOTB_LOG_LEVEL": "TRACE",
        #    "COCOTB_SCHEDULER_DEBUG": "1",
            "SHM_RESET_DEFAULTS": "1",
        #    "SHM_UNPACKED_LIMIT": "131072",
        #    "SHM_PACKED_LIMIT": "131072",
            "COCOTB_HDL_TIMEUNIT": "1ns",
            "COCOTB_HDL_TIMEPRECISION": "1ps",
            "CFILE": cfile,
        },
        pre_cmd=runner_pre_cmd,
    #    pre_cmd=["probe -create -packed 131072 *;"]
        #pre_cmd=[
        #    'set WildcardFilter {};set WildcardSizeThreshold "16777216"; coverage save -onexit covres.ucdb;' #vmap compiled-libs "../../vivado/compiled-libs";'
        #],
        ##test_args=["-L", "compiled-libs"]
        ##test_args=["-L", "../../vivado/compiled-libs"]
        ##test_args=["-modelsimini ../../vivado/modelsim.ini"]
        #test_args=["-suppress", "14408", "-suppress", "16154", "-suppress", "8630", "-modelsimini", "../../../vivado/modelsim.ini", "-L", "compiled-libs", "top.glbl"]
        test_args=runner_test_args
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--sim", type=str, help="Simulator. <icarus, verilator, questa>"
    )
    parser.add_argument(
        "--top", type=str, help="Top level hdl module to test a.k.a DUT"
    )
    parser.add_argument(
        "--test",
        type=str,
        help="Python test file to run, all tests inside will be run",
    )
    parser.add_argument("--waves", type=bool, help="Dump waves? <true,false>")

    parser.add_argument("--cfile", type=str, help="Test file to run")

    args = parser.parse_args()

    test_dir = Path(SCRIPT_DIR / "tb")
    tests = list(test_dir.rglob("*.py"))
    print("test_dir: ", test_dir)
    print("tests: ", tests)

    test_names = {test.stem: test for test in test_dir.rglob("*.py")}

    # if args.test not in test_names:
    #     raise FileNotFoundError(f"Can't find <{args.test}> in <{tests}>")

    try:
        run_test(args.sim, args.test, args.top, args.waves, args.cfile)
    except:
        pass
