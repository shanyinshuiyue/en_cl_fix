###################################################################################################
# Copyright (c) 2023 Enclustra GmbH, Switzerland (info@enclustra.com)
###################################################################################################

###################################################################################################
# Description:
#
# The WideFix class adds arbitrary-precision support to en_cl_fix_pkg.
#
# Internal data is stored in arbitrary-precision Python integers and all calculations are performed
# on (wide) integers. This differs from "narrow" en_cl_fix_pkg calculations, which are performed
# on (double-precision) floats.
#
# Therefore, WideFix internal data is not explicitly normalized according to the fractional bits.
# For example, the fixed-point number 1.25 in FixFormat(0,2,4) has binary representation "01.0100".
# In WideFix this is stored internally as integer value 1.25*2**4 = 20. In "narrow" en_cl_fix_pkg,
# it is stored as float value 1.25.
#
# WideFix executes significantly more slowly than the "narrow" float implementation, but provides
# support for data widths exceeding 53 bits.
###################################################################################################

import warnings
import numpy as np
from copy import copy as shallow_copy
from copy import deepcopy as deep_copy

from .en_cl_fix_types import *


class WideFix:
    
    ###############################################################################################
    # Public Functions 
    ###############################################################################################
    
    # Construct WideFix object from internal integer data representation and FixFormat.
    # Example: the fixed-point value 3.0 in FixFormat(0,2,4) has internal data value 3.0*2**4 = 48
    # and *not* 3.
    def __init__(self, data, fmt : FixFormat, copy=True):
        if isinstance(data, int):
            data = np.array(data)
        assert data.dtype == object, "WideFix: requires arbitrary-precision int (dtype == object)."
        assert isinstance(data.flat[0], int), "WideFix: requires arbitrary-precision int (dtype == object)."
        if copy:
            self._data = data.copy()
        else:
            self._data = data
        # Always copy the format (very small)
        self._fmt = shallow_copy(fmt)
    
    # Convert from float data to WideFix object, with quantization and bounds checks.
    @staticmethod
    def FromFloat(a, rFmt : FixFormat, saturate : FixSaturate = FixSaturate.SatWarn_s):
        # Saturation is mandatory in this function (because wrapping has not been implemented)
        if saturate != FixSaturate.SatWarn_s and saturate != FixSaturate.Sat_s:
            raise ValueError(f"WideFix.FromFloat: Unsupported saturation mode {str(saturate)}")
        if isinstance(a, float):
            a = np.array(a)
        
        # Saturation warning
        if (saturate == FixSaturate.SatWarn_s) or (saturate == FixSaturate.Warn_s):
            amax_float = a.max()
            amin_float = a.min()
            amax = WideFix.FromNarrowFxp(np.array([amax_float]), rFmt)._data
            amin = WideFix.FromNarrowFxp(np.array([amin_float]), rFmt)._data
            if amax > WideFix.MaxValue(rFmt)._data:
                warnings.warn(f"FromFloat: Number {amax_float} exceeds maximum for format {rFmt}", Warning)
            if amin < WideFix.MinValue(rFmt)._data:
                warnings.warn(f"FromFloat: Number {amin_float} exceeds minimum for format {rFmt}", Warning)
        
        # Quantize. Always use half-up rounding.
        x = (a*(2.0**rFmt.F)+0.5).astype('object')
        x = np.floor(x)
        
        # Saturate
        if (saturate == FixSaturate.Sat_s) or (saturate == FixSaturate.SatWarn_s):
            x = np.where(x > WideFix.MaxValue(rFmt)._data, WideFix.MaxValue(rFmt)._data, x)
            x = np.where(x < WideFix.MinValue(rFmt)._data, WideFix.MinValue(rFmt)._data, x)
        else:
            # Wrapping is not supported
            None
        
        return WideFix(x, rFmt)
    
    
    # Convert from narrow (double-precision float) data to WideFix object, without bounds checks.
    @staticmethod
    def FromNarrowFxp(data : np.ndarray, fmt : FixFormat):
        data = np.array(data, ndmin=1)
        assert data.dtype == float, "FromNarrowFxp : requires input dtype == float."
        int_data = (data*2.0**fmt.F).astype(object)
        int_data = np.floor(int_data)
        return WideFix(int_data, fmt)
    
    
    # Convert from uint64 array (e.g. from MATLAB).
    @staticmethod
    def FromUint64Array(data : np.ndarray, fmt : FixFormat):
        assert data.dtype == 'uint64', "FromUint64Array : requires input dtype == uint64."
        # Weighted sum to recombine uint64s into wide *unsigned* integers
        weights = 2**(64*np.arange(data.shape[0]).astype(object))
        val = np.matmul(weights, data)
        # Handle the sign bit
        val = np.where(val >= 2**(fmt.I+fmt.F), val - 2**(fmt.I+fmt.F+1), val)
        return WideFix(val, fmt)
    
    
    # Calculate maximum representable internal data value (WideFix._data) for a given FixFormat.
    @staticmethod
    def MaxValue(fmt : FixFormat):
        val = 2**(fmt.I+fmt.F)-1
        return WideFix._FromIntScalar(val, fmt)
    
    
    # Calculate minimum representable internal data value (WideFix._data) for a given FixFormat.
    @staticmethod
    def MinValue(fmt : FixFormat):
        if fmt.S == 1:
            val = -2**(fmt.I+fmt.F)
        else:
            val = 0
        return WideFix._FromIntScalar(val, fmt)
    
    
    # Align binary points of 2 or more WideFix objects (e.g. to perform numerical comparisons).
    @staticmethod
    def AlignBinaryPoints(values):
        values = deep_copy(values)
        
        # Find the maximum number of frac bits
        Fmax = max(value.fmt.F for value in values)

        # Resize every input to align binary points
        for i, value in enumerate(values):
            rFmt = FixFormat(value.fmt.S, value.fmt.I, Fmax)
            values[i] = value.resize(rFmt)

        return values
    
    
    # Get internal integer data
    @property
    def data(self):
        return self._data.copy()
    
    
    # Get fixed-point format
    @property
    def fmt(self):
        return shallow_copy(self._fmt)
    
    
    # Get data in human-readable floating-point format (with loss of precision), with bounds checks
    def to_float(self):
        # To avoid this warning, call to_narrow_fxp() directly.
        if (self.fmt.S == 1 and (np.any(self.data < -2**52) or np.any(self.data >= 2**52))) \
            or (self.fmt.S == 0 and np.any(self.data >= 2**53)):
            warnings.warn("to_float : Possible loss of precision when converting WideFix data to float!", Warning)
        return self.to_narrow_fxp()
    
    
    # Get narrow (double-precision float) representation of data. No bounds checks.
    def to_narrow_fxp(self):
        # Note: This function performs no range/precision checks.
        return np.array(self._data/2.0**self._fmt.F).astype(float)


    # Pack data into uint64 array (e.g. for passing to MATLAB).
    # Data is packed into columns, so result[:,k] corresponds to data[k].
    def to_uint64_array(self):
        val = self._data
        fmt = self._fmt
        
        # Calculate number of uint64s needed per element
        fmtWidth = fmt.width
        nInts = (fmtWidth + 63) // 64  # ceil(width / 64)

        # Cast to unsigned by reintepreting the sign bit
        val = np.where(val < 0, val + 2**fmtWidth, val)

        # Populate 2D uint64 array
        uint64Array = np.empty((nInts,) + val.shape, dtype='uint64')
        for i in range(nInts):
            uint64Array[i,:] = val % 2**64
            val >>= 64
        
        return uint64Array


    # Create a new WideFix object with a new fixed-point format after rounding.
    def round(self, rFmt : FixFormat, rnd : FixRound = FixRound.Trunc_s):
        assert rFmt == FixFormat.ForRound(self._fmt, rFmt.F, rnd), "round: Invalid result format. Use FixFormat.ForRound()."
        
        # Copy object data so self is not modified and take floor to enforce int object type
        val = np.floor(self._data)
        
        # Shorthands
        fmt = self._fmt
        f = fmt.F
        fr = rFmt.F
        
        # Add offset before truncating to implement rounding
        if fr < f:
            # Frac bits decrease => do rounding
            if rnd is FixRound.Trunc_s:
                # Truncate => Always round towards -Inf.
                pass
            elif rnd is FixRound.NonSymPos_s:
                # Half-up => Round to "nearest", all ties rounded towards +Inf.
                val = val + 2**(f - fr - 1)       # + "half"
            elif rnd is FixRound.NonSymNeg_s:
                # Half-down => Round to "nearest", all ties rounded towards -Inf.
                val = val + (2**(f - fr - 1) - 1) # + "half"-delta
            elif rnd is FixRound.SymInf_s:
                # Half-away-from-zero => Round to "nearest", all ties rounded away from zero.
                #                     => Half-up for val>0. Half-down for val<0.
                offset = np.array(val < 0, dtype=int).astype(object)
                val = val + (2**(f - fr - 1) - offset)
            elif rnd is FixRound.SymZero_s:
                # Half-towards-zero => Round to "nearest", all ties rounded towards zero.
                #                   => Half-up for val<0. Half-down for val>0.
                offset = np.array(val >= 0, dtype=int).astype(object)
                val = val + (2**(f - fr - 1) - offset)
            elif rnd is FixRound.ConvEven_s:
                # Convergent-even => Round to "nearest", all ties rounded to nearest "even" number (b"X..XX0").
                #                 => Half-down for trunc(val) even, else half-up.
                trunc_a = val >> (f - fr)
                trunc_a_iseven = (trunc_a + 1) % 2
                val = val + (2**(f - fr - 1) - trunc_a_iseven*1)
            elif rnd is FixRound.ConvOdd_s:
                # Convergent-odd => Round to "nearest", all ties rounded to nearest "odd" number (b"X..XX1").
                #                => Half-down for trunc(val) odd, else half-up.
                trunc_a = val >> (f - fr)
                trunc_a_isodd = trunc_a % 2
                val = val + (2**(f - fr - 1) - trunc_a_isodd*1)
            else:
                raise Exception("resize : Illegal value for round!")
            
            # Truncate
            shift = f - fr
            val >>= shift
        elif fr > f:
            # Frac bits increase => safely scale up
            val = val * 2**(fr - f)
        else:
            # Frac bits don't change => No rounding or scaling
            pass
            
        return WideFix(val, rFmt)

    # Create a new WideFix object with a new fixed-point format after saturation.
    def saturate(self, rFmt : FixFormat, sat : FixSaturate = FixSaturate.None_s):
        # Copy object data so self is not modified and take floor to enforce int object type
        val = np.floor(self._data)
        
        # Saturation warning
        if sat == FixSaturate.Warn_s or sat == FixSaturate.SatWarn_s:
            if np.any(val > WideFix.MaxValue(rFmt).data) or np.any(val < WideFix.MinValue(rFmt).data):
                warnings.warn("resize : Saturation warning!", Warning)
        
        # Saturation
        if sat == FixSaturate.None_s or sat == FixSaturate.Warn_s:
            # Wrap
            satSpan = 2**(rFmt.I + rFmt.F)
            if rFmt.S == 1:
                val = ((val + satSpan) % (2*satSpan)) - satSpan
            else:
                val = val % satSpan
        else:
            # Saturate
            val = np.where(val > WideFix.MaxValue(rFmt).data, WideFix.MaxValue(rFmt).data, val)
            val = np.where(val < WideFix.MinValue(rFmt).data, WideFix.MinValue(rFmt).data, val)
            
        return WideFix(val, rFmt)

    # Create a new WideFix object with a new fixed-point format after rounding and saturation.
    def resize(self, rFmt : FixFormat,
               rnd : FixRound = FixRound.Trunc_s,
               sat : FixSaturate = FixSaturate.None_s):
        
        # Round
        roundedFmt = FixFormat.ForRound(self._fmt, rFmt.F, rnd)
        rounded = self.round(roundedFmt, rnd)
        
        # Saturate
        result = rounded.saturate(rFmt, sat)
        
        return result
    
    # Create a new WideFix object with the most significant bit (- index) set to "value"
    def set_msb(self, index, value):
        if np.any(value > 1) or np.any(value < 0):
            raise Exception("WideFix.set_msb: only 1 and 0 allowed for value")
        fmt = self.fmt
        if fmt.S == 1 and index == 0:
            weight = -2**(fmt.width-1-index)
        else:
            weight = 2**(fmt.width-1-index)
        val = np.where(self.get_msb(index) != value, self.data - weight*(-1)**value, self.data)
        return WideFix(val, fmt)
    
    
    # Get most significant bit (- index)
    def get_msb(self, index):
        fmt = self._fmt
        if fmt.S == 1 and index == 0:
            return (self._data < 0).astype(int)
        else:
            shift = fmt.width-1 - index
            return ((self._data >> shift) % 2).astype(int)
    
    
    # Discard fractional bits (keeping integer bits). Rounds towards -Inf.
    def floor(self):
        fmt = self._fmt
        rFmt = FixFormat(fmt.S, fmt.I, 0)
        if fmt.F >= 0:
            return WideFix(self._data >> fmt.F, rFmt)
        else:
            return WideFix(self._data << -fmt.F, rFmt)
    
    
    # Get the integer part
    def int_part(self):
        return self.floor()
    
    
    # Get the fractional part.
    # Note: Result has implicit frac bits if I<0.
    def frac_part(self):
        fmt = self._fmt
        rFmt = FixFormat(False, min(fmt.I, 0), fmt.F)
        # Drop the sign bit
        val = self._data
        if fmt.S == 1:
            offset = 2**(fmt.F+fmt.I)
            val = np.where(val < 0, val + offset, val)
        # Retain fractional LSBs
        val = val % 2**rFmt.width
        return WideFix(val, rFmt)


    ###############################################################################################
    # Private Functions 
    ###############################################################################################
    
    # Same as __init__, except the internal integer data is a scalar (arbitrary-precision int).
    @staticmethod
    def _FromIntScalar(data : int, fmt : FixFormat):
        return WideFix(np.array([data]).astype(object), fmt)
    
    # Default string representations: Convert to float for consistency with "narrow" en_cl_fix_pkg.
    # Note: To print raw internal integer data, use print(x.data).
    def __repr__(self):
        return (
            "WideFix : " + repr(self.fmt) + "\n"
            + "Note: Possible loss of precision in float printout.\n"
            + repr(self.to_narrow_fxp())
        )
    
    def __str__(self):
        return (
            f"WideFix {self.fmt}\n"
            f"Note: Possible loss of precision in float printout.\n"
            f"{self.to_narrow_fxp()}"
        )
    
    
    # "+" operator
    def __add__(self, other):
        aFmt = self._fmt
        bFmt = other._fmt
        rFmt = FixFormat.ForAdd(aFmt, bFmt)
        
        a = self.copy()
        b = other.copy()
        
        # Align binary points without truncating any MSBs or LSBs
        aRoundFmt = FixFormat.ForRound(a.fmt, rFmt.F, FixRound.Trunc_s)
        bRoundFmt = FixFormat.ForRound(b.fmt, rFmt.F, FixRound.Trunc_s)
        a = a.round(aRoundFmt)
        b = b.round(bRoundFmt)
        
        # Do addition on internal integer data (binary points are aligned)
        return WideFix(a.data + b.data, rFmt)
    
    
    # "-" operator
    def __sub__(self, other):
        aFmt = self._fmt
        bFmt = other._fmt
        rFmt = FixFormat.ForSub(aFmt, bFmt)
        
        a = self.copy()
        b = other.copy()
        
        # Align binary points without truncating any MSBs or LSBs
        aRoundFmt = FixFormat.ForRound(a.fmt, rFmt.F, FixRound.Trunc_s)
        bRoundFmt = FixFormat.ForRound(b.fmt, rFmt.F, FixRound.Trunc_s)
        a = a.round(aRoundFmt)
        b = b.round(bRoundFmt)
        
        # Do subtraction on internal integer data (binary points are aligned)
        return WideFix(a.data - b.data, rFmt)
    
    # Unary "-" operator
    def __neg__(self):
        rFmt = FixFormat.ForNeg(self._fmt)
        return WideFix(-self._data, rFmt)
    
    
    # "*" operator
    def __mul__(self, other):
        rFmt = FixFormat.ForMult(self._fmt, other.fmt)
        return WideFix(self._data * other.data, rFmt)
    
    
    # Helper function to consistently extract data for comparison operators
    def _extract_comparison_data(self, other):
        # Special case: allow comparisons with integer 0
        if type(other) == int:
            assert other == 0, "WideFix can only be compared with int 0. " + \
            "All other values can be converted using WideFix._FromIntScalar(val, fmt)"
            other = WideFix._FromIntScalar(other, self._fmt)
        # For consistency with narrow implementation, convert to a common format
        a, b = WideFix.AlignBinaryPoints([self, other])
        return a.data, b.data
    
    
    # "==" operator
    def __eq__(self, other):
        a, b = self._extract_comparison_data(other)
        return a == b
    
    
    # "!=" operator
    def __ne__(self, other):
        a, b = self._extract_comparison_data(other)
        return a != b
    
    
    # "<" operator
    def __lt__(self, other):
        a, b = self._extract_comparison_data(other)
        return a < b
    
    
    # "<=" operator
    def __le__(self, other):
        a, b = self._extract_comparison_data(other)
        return a <= b
    
    
    # ">" operator
    def __gt__(self, other):
        a, b = self._extract_comparison_data(other)
        return a > b
    
    
    # ">=" operator
    def __ge__(self, other):
        a, b = self._extract_comparison_data(other)
        return a >= b
    
    
    # len()
    def __len__(self):
        return len(self._data)
