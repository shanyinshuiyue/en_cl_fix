---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library vunit_lib;
    context vunit_lib.vunit_context;
    context vunit_lib.vc_context;

library work;
    context work.en_tb_fix_fileio_context;

---------------------------------------------------------------------------------------------------
-- Entity
---------------------------------------------------------------------------------------------------
entity cl_fix_addsub_tb is
    generic(
        runner_cfg      : string
    );
end cl_fix_addsub_tb;

---------------------------------------------------------------------------------------------------
-- Architecture
---------------------------------------------------------------------------------------------------
architecture rtl of cl_fix_addsub_tb is

    constant DataPath_c         : string := tb_path(runner_cfg) & "../bittrue/cosim/cl_fix_addsub/data/";
    
    -- Formats
    constant AFmt_c             : FixFormatArray_t := cl_fix_read_format_file(DataPath_c & "a_fmt.txt");
    constant BFmt_c             : FixFormatArray_t := cl_fix_read_format_file(DataPath_c & "b_fmt.txt");
    constant RFmt_c             : FixFormatArray_t := cl_fix_read_format_file(DataPath_c & "r_fmt.txt");
    
    -- Rounding and saturation modes
    constant Rnd_c              : integer_vector := read_file(DataPath_c & "rnd.txt", 32);
    constant Sat_c              : integer_vector := read_file(DataPath_c & "sat.txt", 32);
    
    constant TestCount_c        : positive := AFmt_c'length;
    
    signal Clk                  : std_logic := '0';
    
    -- Helper function for printing error info
    function Str(x : integer; XFmt : FixFormat_t) return string is
    begin
        return to_string(cl_fix_to_real(cl_fix_from_integer(x, XFmt), XFmt));
    end function;
    
    function ToStdLogic(x : integer) return std_logic is
    begin
        if x = 1 then
            return '1';
        end if;
        return '0';
    end function;
    
    procedure Check(i : natural) is
        -- Load response data for this test case
        constant Expected_c : SlvArray_t := cl_fix_read_file(DataPath_c & "test" & to_string(i) & "_output.txt", RFmt_c(i));
        constant Amin       : integer := cl_fix_to_integer(cl_fix_min_value(AFmt_c(i)), AFmt_c(i));
        constant Amax       : integer := cl_fix_to_integer(cl_fix_max_value(AFmt_c(i)), AFmt_c(i));
        constant Bmin       : integer := cl_fix_to_integer(cl_fix_min_value(BFmt_c(i)), BFmt_c(i));
        constant Bmax       : integer := cl_fix_to_integer(cl_fix_max_value(BFmt_c(i)), BFmt_c(i));
        variable Idx_v      : natural := 0;
        variable Result_v   : std_logic_vector(cl_fix_width(RFmt_c(i))-1 downto 0);
        variable Operator_v : character;
    begin
        -- The cosim script generates all possible values of both inputs (counters).
        -- We repeat the same pattern here.
        for do_add in 0 to 1 loop
            for b in Bmin to Bmax loop
                for a in Amin to Amax loop
                    -- Calculate result in VHDL
                    Result_v := cl_fix_addsub(
                        cl_fix_from_integer(a, AFmt_c(i)), AFmt_c(i),
                        cl_fix_from_integer(b, BFmt_c(i)), BFmt_c(i),
                        ToStdLogic(do_add),
                        RFmt_c(i), FixRound_t'val(Rnd_c(i)), FixSaturate_t'val(Sat_c(i))
                    );
                    
                    -- Check against cosim
                    if Result_v /= Expected_c(Idx_v) then
                        if do_add = 1 then
                            Operator_v := '+';
                        else
                            Operator_v := '-';
                        end if;
                        
                        print(
                            "Error while calculating " & Str(a, AFmt_c(i)) & " " & to_string(AFmt_c(i)) & " " & Operator_v & " " & Str(b, BFmt_c(i)) & " " & to_string(BFmt_c(i))
                            & " [rnd: " & to_string(FixRound_t'val(Rnd_c(i))) & ", sat: " & to_string(FixSaturate_t'val(Sat_c(i))) & "] --> " & to_string(RFmt_c(i))
                        );
                        check_equal(Result_v, Expected_c(Idx_v), "Error at index " & to_string(Idx_v));
                    end if;
                    Idx_v := Idx_v + 1;
                    
                    -- We don't really need a clock, but it avoids iteration limits in the simulator
                    -- (and avoids confusion for a developer seeing the time stuck at 0 ns).
                    wait until rising_edge(Clk);
                end loop;
            end loop;
        end loop;
    end procedure;
    
begin
    
    test_runner_watchdog(runner, 100 ms);
    
    Clk <= not Clk after 5 ns;
    
    ----------------
    -- VUnit Main --
    ----------------
    p_main : process
    begin
        test_runner_setup(runner, runner_cfg);
        
        wait until rising_edge(Clk);
        
        while test_suite loop
            if run("test") then
                for i in 0 to TestCount_c-1 loop
                    Check(i);
                end loop;
            end if;
        end loop;
        
        print("SUCCESS! All tests passed.");
        test_runner_cleanup(runner);
    end process;
    
end rtl;
