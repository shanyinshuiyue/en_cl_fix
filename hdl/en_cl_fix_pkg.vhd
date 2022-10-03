---------------------------------------------------------------------------------------------------
-- Copyright (c) 2022 Enclustra GmbH, Switzerland (info@enclustra.com)
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

library work;
    use work.en_cl_fix_private_pkg.all;

---------------------------------------------------------------------------------------------------
-- Package Header
---------------------------------------------------------------------------------------------------

package en_cl_fix_pkg is

    -----------------------------------------------------------------------------------------------
    -- Types
    -----------------------------------------------------------------------------------------------
    
    type FixFormat_t is record
        S   : natural range 0 to 1;  -- Sign bit.
        I   : integer;               -- Integer bits.
        F   : integer;               -- Fractional bits.
    end record;
    
    type FixFormatArray_t is array(natural range <>) of FixFormat_t;
    
    type FixRound_t is
    (
        Trunc_s,        -- Discard LSBs.
        NonSymPos_s,    -- Non-symmetric rounding towards +infinity.
        NonSymNeg_s,    -- Non-symmetric rounding towards -infinity.
        SymInf_s,       -- Symmetric rounding towards +/- infinity.
        SymZero_s,      -- Symmetric rounding towards zero.
        ConvEven_s,     -- Convergent rounding to even number.
        ConvOdd_s       -- Convergent rounding to odd number.
    );
    
    type FixSaturate_t is
    (
        None_s,         -- No saturation, no warning.
        Warn_s,         -- No saturation, only warning.
        Sat_s,          -- Only saturation, no warning.
        SatWarn_s       -- Saturation and warning.
    );
    
    -----------------------------------------------------------------------------------------------
    -- Format Functions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_width(fmt : FixFormat_t) return natural;
    
    function cl_fix_max_value(fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_min_value(fmt : FixFormat_t) return std_logic_vector;
    
    function cl_fix_add_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_sub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_addsub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_mult_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_neg_fmt(a_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_abs_fmt(a_fmt : FixFormat_t) return FixFormat_t;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; min_shift : integer; max_shift : integer) return FixFormat_t;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; shift : integer) return FixFormat_t;
    
    function cl_fix_round_fmt(a_fmt : FixFormat_t; r_frac_bits : integer; rnd : FixRound_t) return FixFormat_t;
    
    -----------------------------------------------------------------------------------------------
    -- String Conversions
    -----------------------------------------------------------------------------------------------
    
    function to_string(fmt : FixFormat_t) return string;
    
    function to_string(rnd : FixRound_t) return string;
    
    function to_string(sat : FixSaturate_t) return string;
    
    function cl_fix_format_from_string(Str : string) return FixFormat_t;
    
    function cl_fix_round_from_string(Str : string) return FixRound_t;
    
    function cl_fix_saturate_from_string(Str : string) return FixSaturate_t;

    -----------------------------------------------------------------------------------------------
    -- Type Conversions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_from_real(a : real; result_fmt : FixFormat_t; saturate : FixSaturate_t := SatWarn_s) return std_logic_vector;
    
    function cl_fix_to_real(a : std_logic_vector; a_fmt : FixFormat_t) return real;
    
    function cl_fix_get_bits_as_int(a : std_logic_vector; aFmt : FixFormat_t) return integer;
    
    function cl_fix_from_bits_as_int(a : integer; aFmt : FixFormat_t) return std_logic_vector;

    -----------------------------------------------------------------------------------------------
    -- Rounding and Saturation
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_round(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s
    ) return std_logic_vector;
    
    function cl_fix_saturate(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_resize(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_in_range(a : std_logic_vector; a_fmt : FixFormat_t; result_fmt : FixFormat_t; round : FixRound_t := Trunc_s) return boolean;
    
    -----------------------------------------------------------------------------------------------
    -- Math Functions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_abs(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_neg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_add(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_sub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_addsub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_shift(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        shift       : integer;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_mult(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector;
    
    function cl_fix_compare(
        comparison  : string;
        a           : std_logic_vector;
        aFmt        : FixFormat_t;
        b           : std_logic_vector;
        bFmt        : FixFormat_t
    ) return boolean;
    
    function cl_fix_sign(a : std_logic_vector; aFmt : FixFormat_t) return std_logic;
    
end package;

---------------------------------------------------------------------------------------------------
-- Package Body
---------------------------------------------------------------------------------------------------

package body en_cl_fix_pkg is
    
    -----------------------------------------------------------------------------------------------
    -- Internal Functions
    -----------------------------------------------------------------------------------------------
    
    function max_real(fmt : FixFormat_t) return real is
    begin
        return 2.0**fmt.I - 2.0**(-fmt.F);
    end function;
    
    function min_real(fmt : FixFormat_t) return real is
    begin
        if fmt.S = 1 then
            return -2.0**fmt.I;
        else
            return 0.0;
        end if;
    end function;
    
    function get_half(aFmt, rFmt : FixFormat_t) return unsigned is
        constant tie_c  : natural := aFmt.F - rFmt.F - 1;
        variable v      : unsigned(cl_fix_width(aFmt)-1 downto 0) := (others => '0');
    begin
        -- Set the "tie" bit (i.e. half the LSB weight of rFmt)
        v(tie_c) := '1';
        return v;
    end function;
    
    function get_unit_bit(a : std_logic_vector; aFmt, rFmt : FixFormat_t) return std_logic is
        constant unit_c : natural := aFmt.F - rFmt.F;
    begin
        if unit_c >= cl_fix_width(aFmt) then
            -- Implicit MSB extension
            return cl_fix_sign(a, aFmt);
        else
            -- Normal behavior: get the explicit "unit" bit (i.e. the LSB weight of rFmt)
            return a(unit_c);
        end if;
    end function;
    
    -- Avoid collision between min() function and minutes unit in VHDL std library.
    alias min is work.en_cl_fix_private_pkg.min[integer, integer return integer];
    
    -----------------------------------------------------------------------------------------------
    -- Public Functions
    -----------------------------------------------------------------------------------------------
    
    function cl_fix_width(fmt : FixFormat_t) return natural is
    begin
        return fmt.S + fmt.I + fmt.F;
    end;
    
    function cl_fix_max_value(fmt : FixFormat_t) return std_logic_vector is
        variable result_v : std_logic_vector(cl_fix_width(fmt)-1 downto 0);
    begin
        result_v := (others => '1');
        if fmt.S = 1 then
            result_v(result_v'high) := '0';
        end if;
        return result_v;
    end;
    
    function cl_fix_min_value(fmt : FixFormat_t) return std_logic_vector is
        variable result_v : std_logic_vector(cl_fix_width(fmt)-1 downto 0);
    begin
        if fmt.S = 1 then
            result_v := (others => '0');
            result_v(result_v'left) := '1';
        else
            result_v := (others => '0');
        end if;
        return result_v;
    end;
    
    function cl_fix_add_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        -- We must consider both extremes:
        
        -- rmax = amax+bmax
        --      = (2**aFmt.I - 2**-aFmt.F) + (2**bFmt.I - 2**-bFmt.F)
        -- If we denote the format with max(aFmt.I, bFmt.I) int bits as "maxFmt" and the other
        -- format as "minFmt", then we get 1 bit of growth if 2**minFmt.I > 2**-maxFmt.F.
        constant rmax_growth_c  : natural := choose((a_fmt.I >= b_fmt.I and b_fmt.I > -a_fmt.F) or (a_fmt.I < b_fmt.I and a_fmt.I > -b_fmt.F), 1, 0);
        
        -- rmin = amin+bmin
        --     If aFmt.S = 0 and bFmt.S = 0: 0 + 0
        --     If aFmt.S = 0 and bFmt.S = 1: 0 + -2**bFmt.I
        --     If aFmt.S = 1 and bFmt.S = 0: -2**aFmt.I + 0
        --     If aFmt.S = 1 and bFmt.S = 1: -2**aFmt.I + -2**bFmt.I
        constant rmin_growth_c  : natural := choose(a_fmt.S = 1 and b_fmt.S = 1, 1, 0);
    begin
        return (
            max(a_fmt.S, b_fmt.S),
            max(a_fmt.I, b_fmt.I) + max(rmin_growth_c, rmax_growth_c),
            max(a_fmt.F, b_fmt.F)
        );
    end;
    
    function cl_fix_sub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        -- We must consider both extremes:
        
        -- rmax = amax-bmin
        --     If bFmt.S = 0: rmax = (2**aFmt.I - 2**-aFmt.F) - 0
        --     If bFmt.S = 1: rmax = (2**aFmt.I - 2**-aFmt.F) + 2**bFmt.I
        -- We get 1 bit of growth in the signed case if -2**-aFmt.F + 2**bFmt.I >= 0.
        constant rmax_growth_c  : natural := choose(b_fmt.I >= -a_fmt.F, b_fmt.S, 0);
        
        -- rmin = amin-bmax
        --     If aFmt.S = 0: rmin = 0 - (2**bFmt.I - 2**-bFmt.F)
        --     If aFmt.S = 1: rmin = -2**aFmt.I - (2**bFmt.I - 2**-bFmt.F)
        -- We get 1 bit of growth in the signed case if -2**aFmt.I + 2**-bFmt.F < 0.
        constant rmin_growth_c  : natural := choose(a_fmt.I > -b_fmt.F, a_fmt.S, 0);
    begin
        return (
            1,
            max(a_fmt.I, b_fmt.I) + max(rmin_growth_c, rmax_growth_c),
            max(a_fmt.F, b_fmt.F)
        );
    end;
    
    function cl_fix_addsub_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        constant add_fmt_c  : FixFormat_t := cl_fix_add_fmt(a_fmt, b_fmt);
        constant sub_fmt_c  : FixFormat_t := cl_fix_sub_fmt(a_fmt, b_fmt);
    begin
        return (
            max(add_fmt_c.S, sub_fmt_c.S),
            max(add_fmt_c.I, sub_fmt_c.I),
            max(add_fmt_c.F, sub_fmt_c.F)
        );
    end;
    
    function cl_fix_mult_fmt(a_fmt : FixFormat_t; b_fmt : FixFormat_t) return FixFormat_t is
        -- We get 1 bit of growth for signed*signed (rmax = -2**aFmt.I * -2**bFmt.I).
        constant Growth_c   : natural := min(a_fmt.S, b_fmt.S);
        constant Signed_c   : natural := max(a_fmt.S, b_fmt.S);
    begin
        return (Signed_c, a_fmt.I + b_fmt.I + Growth_c, a_fmt.F + b_fmt.F);
    end;
    
    function cl_fix_neg_fmt(a_fmt : FixFormat_t) return FixFormat_t is
    begin
        -- We get 1 bit of growth for signed inputs due to the asymmetry of two's complement.
        return (1, a_fmt.I + a_fmt.S, a_fmt.F);
    end;
    
    function cl_fix_abs_fmt(a_fmt : FixFormat_t) return FixFormat_t is
        constant neg_fmt_c  : FixFormat_t := cl_fix_neg_fmt(a_fmt);
    begin
        return (
            max(a_fmt.S, neg_fmt_c.S),
            max(a_fmt.I, neg_fmt_c.I),
            max(a_fmt.F, neg_fmt_c.F)
        );
    end;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; min_shift : integer; max_shift : integer) return FixFormat_t is
    begin
        assert min_shift <= max_shift report "min_shift must be <= max_shift" severity Failure;
        
        return (a_fmt.S, a_fmt.I + max_shift, a_fmt.F - min_shift);
    end;
    
    function cl_fix_shift_fmt(a_fmt : FixFormat_t; shift : integer) return FixFormat_t is
    begin
        return cl_fix_shift_fmt(a_fmt, shift, shift);
    end;
    
    function cl_fix_round_fmt(a_fmt : FixFormat_t; r_frac_bits : integer; rnd : FixRound_t) return FixFormat_t is
        variable growth_v   : natural;
    begin
        if r_frac_bits >= a_fmt.F then
            -- If fractional bits are not being reduced, then nothing happens to int bits.
            growth_v := 0;
        elsif rnd = Trunc_s then
            -- Crude truncation has no effect on int bits.
            growth_v := 0;
        else
            -- All other rounding modes can overflow into +1 int bit.
            growth_v := 1;
        end if;
        
        return (a_fmt.S, a_fmt.I + growth_v, r_frac_bits);
    end;
    
    function to_string(fmt : FixFormat_t) return string is
    begin
        return "(" & natural'image(fmt.S) & "," & integer'image(fmt.I) & "," & integer'image(fmt.F) & ")";
    end;
    
    function to_string(rnd : FixRound_t) return string is
    begin
        -- Some synthesis tools do not support FixRound_t'image(), so we implement explicitly.
        case rnd is
            when Trunc_s     => return "Trunc_s";
            when NonSymPos_s => return "NonSymPos_s";
            when NonSymNeg_s => return "NonSymNeg_s";
            when SymInf_s    => return "SymInf_s";
            when SymZero_s   => return "SymZero_s";
            when ConvEven_s  => return "ConvEven_s";
            when ConvOdd_s   => return "ConvOdd_s";
            when others => report "to_string(FixRound_t) : Unsupported input." severity Failure;
        end case;
        return "";
    end;
    
    function to_string(sat : FixSaturate_t) return string is
    begin
        -- Some synthesis tools do not support FixSaturate_t'image(), so we implement explicitly.
        case sat is
            when None_s    => return "None_s";
            when Warn_s    => return "Warn_s";
            when Sat_s     => return "Sat_s";
            when SatWarn_s => return "SatWarn_s";
            when others => report "to_string(FixSaturate_t) : Unsupported input." severity Failure;
        end case;
        return "";
    end;
    
    function cl_fix_format_from_string(Str : string) return FixFormat_t is
        variable Format_v   : FixFormat_t;
        variable Index_v    : integer;
    begin
        -- Parse Format
        Index_v := Str'low;
        Index_v := string_find_next_match(Str, '(', Index_v);
        assert Index_v > 0
            report "cl_fix_format_from_string: Format string is missing '('" severity Failure;
        -- Number of sign bits must be 0 or 1
        if Str(Index_v+1) = '0' then
            Format_v.S := 0;
        elsif Str(Index_v+1) = '1' then
            Format_v.S := 1;
        else
            report "cl_fix_format_from_string: Unsupported number of sign bits: " & Str(Index_v+1) severity Failure;
        end if;
        Index_v := string_find_next_match(Str, ',', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: Format string is missing ',' between S and I" severity Failure;
        Format_v.I := string_parse_int(Str, Index_v+1);
        Index_v := string_find_next_match(Str, ',', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: Format string is missing ',' between I and F" severity Failure;
        Format_v.F := string_parse_int(Str, Index_v+1);
        Index_v := string_find_next_match(Str, ')', Index_v+1);
        assert Index_v > 0
            report "cl_fix_format_from_string: Format string is missing ')'" severity Failure;
        return Format_v;
    end;
    
    function cl_fix_round_from_string(Str : string) return FixRound_t is
        constant StrLower_c : string := toLower(Str);
    begin
        if StrLower_c = "trunc_s" then
            return Trunc_s;
        elsif StrLower_c = "nonsympos_s" then
            return NonSymPos_s;
        elsif StrLower_c = "nonsymneg_s" then
            return NonSymNeg_s;
        elsif StrLower_c = "syminf_s" then
            return SymInf_s;
        elsif StrLower_c = "symzero_s" then
            return SymZero_s;
        elsif StrLower_c = "conveven_s" then
            return ConvEven_s;
        elsif StrLower_c = "convodd_s" then
            return ConvOdd_s;
        end if;
        
        report "cl_fix_round_from_string: unrecognized format " & Str severity failure;
        return Trunc_s;
    end;
    
    function cl_fix_saturate_from_string(Str : string) return FixSaturate_t is
        constant StrLower_c : string := toLower(Str);
    begin
        if StrLower_c = "none_s" then
            return None_s;
        elsif StrLower_c = "warn_s" then
            return Warn_s;
        elsif StrLower_c = "sat_s" then
            return Sat_s;
        elsif StrLower_c = "satwarn_s" then
            return SatWarn_s;
        end if;
        
        report "cl_fix_saturate_from_string: unrecognized format " & Str severity failure;
        return None_s;
    end;
    
    function cl_fix_from_real(a : real; result_fmt : FixFormat_t; saturate : FixSaturate_t := SatWarn_s) return std_logic_vector is
        constant ChunkSize_c    : positive := 30;
        constant ChunkCount_c   : positive := (cl_fix_width(result_fmt) + ChunkSize_c - 1)/ChunkSize_c;
        variable ASat_v         : real;
        variable Chunk_v        : std_logic_vector(ChunkSize_c-1 downto 0);
        variable Result_v       : std_logic_vector(ChunkSize_c*ChunkCount_c-1 downto 0);
    begin
        -- Limit
        if a > max_real(result_fmt) then
            ASat_v := max_real(result_fmt);
        elsif a < min_real(result_fmt) then
            ASat_v := min_real(result_fmt);
        else
            ASat_v := a;
        end if;
        
        -- Rescale to appropriate fractional bits
        ASat_v := round(ASat_v * 2.0**(result_fmt.F));
        
        -- Convert to fixed-point in chunks
        for i in 0 to ChunkCount_c-1 loop
            -- Note: Due to a Xilinx Vivado bug, we must explicitly call the math_real mod operator
            Chunk_v := std_logic_vector(to_unsigned(integer(ieee.math_real."mod"(ASat_v, 2.0**ChunkSize_c)), ChunkSize_c));
            Result_v((i+1)*ChunkSize_c-1 downto i*ChunkSize_c) := Chunk_v;
            ASat_v := floor(ASat_v/2.0**ChunkSize_c);
        end loop;
        
        return Result_v(cl_fix_width(result_fmt)-1 downto 0);
    end;
    
    function cl_fix_to_real(a : std_logic_vector; a_fmt : FixFormat_t) return real is
        constant ABits_c        : positive := cl_fix_width(a_fmt);
        constant ChunkSize_c    : positive := 30;
        constant ChunkCount_c   : positive := (ABits_c + ChunkSize_c - 1)/ChunkSize_c;
        variable a_v            : std_logic_vector(a'length-1 downto 0);
        variable Correction_v   : real := 0.0;
        variable apad_v         : unsigned(ChunkSize_c*ChunkCount_c-1 downto 0);
        variable Chunk_v        : unsigned(ChunkSize_c-1 downto 0);
        variable result_v       : real := 0.0;
    begin
        -- Enforce 'downto' bit order
        a_v := a;
        
        -- Handle sign bit
        if a_fmt.S = 1 and a_v(ABits_c-1) = '1' then
            a_v(ABits_c-1) := '0'; -- Clear sign bit.
            Correction_v := -2.0**(ABits_c-1 - a_fmt.F); -- Remember its weight.
        end if;
        
        -- Resize to an integer number of chunks
        apad_v := resize(unsigned(a_v), ChunkSize_c*ChunkCount_c);
        
        -- Convert to real in chunks
        for i in ChunkCount_c-1 downto 0 loop
            result_v := result_v * 2.0**ChunkSize_c; -- Shift to next chunk.
            Chunk_v := apad_v((i+1)*ChunkSize_c-1 downto i*ChunkSize_c);
            result_v := result_v + real(to_integer(Chunk_v)) * 2.0**(-a_fmt.F);
        end loop;
        
        -- Add sign bit contribution
        result_v := result_v + Correction_v;
        
        return result_v;
    end;
    
    function cl_fix_from_bits_as_int(a : integer; aFmt : FixFormat_t) return std_logic_vector is
    begin
        if aFmt.S = 1 then
            return std_logic_vector(to_signed(a, cl_fix_width(aFmt)));
        else
            return std_logic_vector(to_unsigned(a, cl_fix_width(aFmt)));
        end if;
    end function;
    
    function cl_fix_get_bits_as_int(a : std_logic_vector; aFmt : FixFormat_t) return integer is
    begin
        -- Modelsim throws warnings if to_integer() is called on 1-bit signed or any 0-bit input.
        -- We handle these special cases explicitly to avoid the warnings.
        if cl_fix_width(aFmt) = 0 then
            return 0;
        elsif aFmt.S = 1 and cl_fix_width(aFmt) = 1 then
            if a(0) = '1' then
                -- Note: -1 in the integer representation is -2**aFmt.I in fixed point.
                return -1;
            else
                return 0;
            end if;
        end if;
        
        -- Normal cases
        if aFmt.S = 1 then
            return to_integer(signed(a));
        else
            return to_integer(unsigned(a));
        end if;
    end function;
    
    function cl_fix_round(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s
    ) return std_logic_vector is
        -- The result format takes care of potential integer growth due to the rounding mode.
        -- In the intermediate calculation, we need to +/- 2.0**-(result_fmt.F+1) in order to
        -- implement each rounding algorithm (except trivial Trunc_s).
        constant frac_growth_c  : natural := choose(round = Trunc_s, 0, 1);
        constant mid_fmt_c      : FixFormat_t := (
            result_fmt.S,
            result_fmt.I,
            max(result_fmt.F+1, a_fmt.F)
        );
        constant in_offset_c        : natural := mid_fmt_c.F - a_fmt.F;
        constant out_offset_c       : natural := mid_fmt_c.F - result_fmt.F;
        constant half_c             : unsigned(cl_fix_width(mid_fmt_c)-1 downto 0) := get_half(mid_fmt_c, result_fmt);
        constant sign_c             : std_logic := cl_fix_sign(a, a_fmt);
        variable unit_v             : std_logic;
        variable mid_v              : unsigned(cl_fix_width(mid_fmt_c)-1 downto 0) := (others => '0');
    begin
        assert result_fmt = cl_fix_round_fmt(a_fmt, result_fmt.F, round)
            report "cl_fix_round: Invalid result format. Use cl_fix_round_fmt()." severity Failure;
        
        -- Write the input value into mid_v with correct binary point alignment.
        -- We sign extend into any extra int bits (and in_offset_c LSBs are defaulted to '0').
        if a_fmt.S = 0 then
            mid_v(mid_v'high downto in_offset_c) := resize(unsigned(a), mid_v'length - in_offset_c);
        else
            mid_v(mid_v'high downto in_offset_c) := unsigned(resize(signed(a), mid_v'length - in_offset_c));
        end if;
        
        -- To implement each rounding algorithm, we add an appropriate offset before truncating.
        if result_fmt.F < a_fmt.F then
            
            -- Get the least significant bit in the result format (for convergent rounding)
            unit_v := get_unit_bit(std_logic_vector(mid_v), mid_fmt_c, result_fmt);
            
            case round is
                when Trunc_s =>
                    null;  -- Crude truncation => no offset.
                when NonSymPos_s =>
                    mid_v := mid_v + half_c;
                when NonSymNeg_s =>
                    mid_v := mid_v + (half_c-1);
                when SymInf_s =>
                    mid_v := mid_v + half_c - ("" & sign_c);
                when SymZero_s =>
                    mid_v := mid_v + half_c - ("" & not sign_c);
                when ConvEven_s =>
                    mid_v := mid_v + half_c - ("" & not unit_v);
                when ConvOdd_s =>
                    mid_v := mid_v + half_c - ("" & unit_v);
                when others => report "Unrecognized rounding mode: " & to_string(round) severity Failure;
            end case;
        end if;
        
        -- Truncate
        return std_logic_vector(mid_v(cl_fix_width(result_fmt)+out_offset_c-1 downto out_offset_c));
    end;
    
    function cl_fix_saturate(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        
        constant ResultWidth_c      : positive := cl_fix_width(result_fmt);
        constant CutFracBits_c      : natural := a_fmt.F - result_fmt.F;
        constant CutIntSignBits_c   : integer := cl_fix_width(a_fmt) - (ResultWidth_c+CutFracBits_c);
        
        variable a_v                : unsigned(cl_fix_width(a_fmt)-1 downto 0);
        
    begin
        a_v := unsigned(a);
        
        if CutIntSignBits_c > 0 and saturate /= None_s then -- saturation required
            if result_fmt.S = 1 then -- signed output
                if to_01(a_v(a_v'high downto a_v'high-CutIntSignBits_c)) /= 0 and
                        not a_v(a_v'high downto a_v'high-CutIntSignBits_c) /= 0 then
                    assert saturate = Sat_s report "cl_fix_resize : Saturation Warning!" severity warning;
                    if saturate /= Warn_s then
                        a_v(a_v'high-1 downto 0) := (others => not a_v(a_v'high));
                        a_v(ResultWidth_c+CutFracBits_c-1) := a_v(a_v'high);
                    end if;
                end if;
            else -- unsigned output
                if to_01(a_v(a_v'high downto a_v'high-CutIntSignBits_c+1)) /= 0 then
                    assert saturate = Sat_s report "cl_fix_resize : Saturation Warning!" severity warning;
                    if saturate /= Warn_s then
                        a_v := (others => not a_v(a_v'high));
                    end if;
                end if;
            end if;
        end if;
        
        return std_logic_vector(a_v(ResultWidth_c+CutFracBits_c-1 downto CutFracBits_c));
    end;
    
    function cl_fix_resize(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        -- Round
        constant rounded_fmt_c  : FixFormat_t := cl_fix_round_fmt(a_fmt, result_fmt.F, round);
        constant rounded_c      : std_logic_vector := cl_fix_round(a, a_fmt, rounded_fmt_c, round);
    begin
        -- Saturate
        return cl_fix_saturate(rounded_c, rounded_fmt_c, result_fmt, saturate);
    end;
    
    function cl_fix_in_range(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s
    ) return boolean is
        -- Note: This matches the python implementation
        constant rndFmt_c : FixFormat_t :=
            (
                S   => a_fmt.S,
                I   => a_fmt.I + 1,
                F   => result_fmt.F
            );
        
        -- Apply rounding
        constant Rounded_c  : std_logic_vector := cl_fix_resize(a, a_fmt, rndFmt_c, round, Sat_s);
    begin
        return cl_fix_compare("a>=b", Rounded_c, rndFmt_c, cl_fix_min_value(result_fmt), result_fmt) and
               cl_fix_compare("a<=b", Rounded_c, rndFmt_c, cl_fix_max_value(result_fmt), result_fmt);
    end;
    
    function cl_fix_abs(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant TempFmt_c  : FixFormat_t :=
            (
                S   => a_fmt.S,
                I   => a_fmt.I + a_fmt.S,
                F   => a_fmt.F
            );
        variable a_v        : std_logic_vector(a'length-1 downto 0);
        variable temp_v     : std_logic_vector(cl_fix_width(TempFmt_c)-1 downto 0);
    begin
        a_v := a;
        if a_fmt.S = 1 then
            temp_v := a_v(a_v'high) & a_v;
            if a_v(a_v'high) = '1' then
                temp_v := std_logic_vector(unsigned(not temp_v) + 1);
            end if;
        else
            temp_v := a_v;
        end if;
        return cl_fix_resize(temp_v, TempFmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_neg(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_neg_fmt(a_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, mid_fmt_c);
        mid_v := std_logic_vector(-signed(a_v));
        return cl_fix_resize(mid_v, mid_fmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_add(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_add_fmt(a_fmt, b_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable b_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, mid_fmt_c, Trunc_s, None_s);
        b_v := cl_fix_resize(b, b_fmt, mid_fmt_c, Trunc_s, None_s);
        -- Signed/unsigned addition/subtraction are identical when using two's complement.
        -- However, a long-standing Vivado bug causes incorrect post-synthesis behavior in DSP
        -- slices (pre-add or post-add) if numeric_std.unsigned is used. There are no known issues
        -- for numeric_std.signed, so we always use that.
        mid_v := std_logic_vector(signed(a_v) + signed(b_v));
        return cl_fix_resize(mid_v, mid_fmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_sub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        constant mid_fmt_c  : FixFormat_t := cl_fix_sub_fmt(a_fmt, b_fmt);
        variable a_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable b_v        : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable mid_v      : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
    begin
        a_v := cl_fix_resize(a, a_fmt, mid_fmt_c, Trunc_s, None_s);
        b_v := cl_fix_resize(b, b_fmt, mid_fmt_c, Trunc_s, None_s);
        -- Signed/unsigned addition/subtraction are identical when using two's complement.
        -- However, a long-standing Vivado bug causes incorrect post-synthesis behavior in DSP
        -- slices (pre-add or post-add) if numeric_std.unsigned is used. There are no known issues
        -- for numeric_std.signed, so we always use that.
        mid_v := std_logic_vector(signed(a_v) - signed(b_v));
        return cl_fix_resize(mid_v, mid_fmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_addsub(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        add         : std_logic;
        result_fmt  : FixFormat_t;
        round       : FixRound_t := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        variable result_v   : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        if to01(add) = '1' then
            result_v := cl_fix_add(a, a_fmt, b, b_fmt, result_fmt, round, saturate);
        else
            result_v := cl_fix_sub(a, a_fmt, b, b_fmt, result_fmt, round, saturate);
        end if;
        return result_v;
    end;
    
    function cl_fix_shift(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        shift       : integer;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        -- Implicitly shift by resizing to a dummy format, then reinterpreting as result_fmt.
        constant dummy_fmt_c  : FixFormat_t := (result_fmt.S, result_fmt.I - shift, result_fmt.F + shift);
    begin
        -- Note: This function performs a lossless shift (equivalent to *2.0**shift), then resizes
        --       to the output format. The initial shift does NOT truncate any bits.
        -- Note: "shift" direction is left. (So shift<0 shifts right).
        return cl_fix_resize(a, a_fmt, dummy_fmt_c, round, saturate);
    end;
    
    function cl_fix_mult(
        a           : std_logic_vector;
        a_fmt       : FixFormat_t;
        b           : std_logic_vector;
        b_fmt       : FixFormat_t;
        result_fmt  : FixFormat_t;
        round       : FixRound_t    := Trunc_s;
        saturate    : FixSaturate_t := Warn_s
    ) return std_logic_vector is
        -- VHDL doesn't define a * operator for mixed signed*unsigned or unsigned*signed.
        -- Just inside cl_fix_mult, it is safe to define them for local use.
        function "*"(x : signed; y : unsigned) return signed is
            constant Temp_c : signed := x * ('0' & signed(y));
        begin
            -- Drop the redundant MSB
            return Temp_c(Temp_c'high-1 downto Temp_c'low);
        end function;
        
        function "*"(x : unsigned; y : signed) return signed is
        begin
            return y * x;
        end function;
        
        constant mid_fmt_c      : FixFormat_t := cl_fix_mult_fmt(a_fmt, b_fmt);
        variable mid_v          : std_logic_vector(cl_fix_width(mid_fmt_c)-1 downto 0);
        variable result_v       : std_logic_vector(cl_fix_width(result_fmt)-1 downto 0);
    begin
        if a_fmt.S = 0 and b_fmt.S = 0 then
            mid_v := std_logic_vector(unsigned(a) * unsigned(b));
        elsif a_fmt.S = 0 and b_fmt.S = 1 then
            mid_v := std_logic_vector(unsigned(a) *   signed(b));
        elsif a_fmt.S = 1 and b_fmt.S = 0 then
            mid_v := std_logic_vector(  signed(a) * unsigned(b));
        else
            mid_v := std_logic_vector(  signed(a) *   signed(b));
        end if;
        
        return cl_fix_resize(mid_v, mid_fmt_c, result_fmt, round, saturate);
    end;
    
    function cl_fix_compare(
        comparison  : string;
        a           : std_logic_vector;
        aFmt        : FixFormat_t;
        b           : std_logic_vector;
        bFmt        : FixFormat_t
    ) return boolean is
        constant FullFmt_c  : FixFormat_t   := (max(aFmt.S, bFmt.S), max(aFmt.I, bFmt.I), max(aFmt.F, bFmt.F));
        variable AFull_v    : std_logic_vector(cl_fix_width(FullFmt_c)-1 downto 0);
        variable BFull_v    : std_logic_vector(cl_fix_width(FullFmt_c)-1 downto 0);
    begin
        -- Convert to same type
        AFull_v := cl_fix_resize(a, aFmt, FullFmt_c);
        BFull_v := cl_fix_resize(b, bFmt, FullFmt_c);
        
        -- Compare
        if FullFmt_c.S = 1 then
            if    comparison = "="  then return signed(AFull_v) =  signed(BFull_v);
            elsif comparison = "!=" then return signed(AFull_v) /= signed(BFull_v);
            elsif comparison = "<"  then return signed(AFull_v) <  signed(BFull_v);
            elsif comparison = ">"  then return signed(AFull_v) >  signed(BFull_v);
            elsif comparison = "<=" then return signed(AFull_v) <= signed(BFull_v);
            elsif comparison = ">=" then return signed(AFull_v) >= signed(BFull_v);
            else
                report "cl_fix_compare: Unrecognized comparison type: " & comparison severity Failure;
                return false;
            end if;
        else
            if    comparison = "="  then return unsigned(AFull_v) =  unsigned(BFull_v);
            elsif comparison = "!=" then return unsigned(AFull_v) /= unsigned(BFull_v);
            elsif comparison = "<"  then return unsigned(AFull_v) <  unsigned(BFull_v);
            elsif comparison = ">"  then return unsigned(AFull_v) >  unsigned(BFull_v);
            elsif comparison = "<=" then return unsigned(AFull_v) <= unsigned(BFull_v);
            elsif comparison = ">=" then return unsigned(AFull_v) >= unsigned(BFull_v);
            else
                report "cl_fix_compare: Unrecognized comparison type: " & comparison severity Failure;
                return false;
            end if;
        end if;
        
    end function;
    
    function cl_fix_sign(a : std_logic_vector; aFmt : FixFormat_t) return std_logic is
    begin
        if aFmt.S = 0 or cl_fix_width(aFmt) = 0 then
            return '0';
        end if;
        return a(a'high);
    end function;
end;
