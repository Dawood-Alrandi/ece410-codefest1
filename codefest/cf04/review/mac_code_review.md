# MAC Unit Code Review
ECE 410/510 Codefest 4, HW4AI Spring 2026

## LLM Models Used

| File | LLM Used | Model Version |
|------|----------|---------------|
| mac_llm_A.v | Anthropic Claude | Claude Sonnet 4.6 |
| mac_llm_B.v | OpenAI ChatGPT | GPT-4o (gpt-4o-2024-11-20) |

## Simulation Log

I ran the testbench using Icarus Verilog and all tests passed:

```
VCD info: dumpfile mac_tb.vcd opened for output.
PASS cycle 1: out=12
PASS cycle 2: out=24
PASS cycle 3: out=36
PASS reset: out=0
PASS cycle 5: out=-10
PASS cycle 6: out=-20

All tests PASSED.
```

## Issue 1: Wrong Process Type in mac_llm_B.v

The spec says to use always_ff but mac_llm_B.v uses plain always instead.

Offending lines from mac_llm_B.v:

```verilog
always @(posedge clk) begin
    if (rst)
        out <= 32'b0;
    else
        out <= out + product;
end
```

Why it is wrong: The spec requires synthesizable SystemVerilog using always_ff. Using always instead of always_ff is a specification violation. Tools like Yosys with strict SystemVerilog mode will warn or reject this. The always_ff keyword tells the simulator and synthesizer this is a flip-flop process and will error if you accidentally put non-edge-triggered logic inside it, which makes the code safer.

Corrected version:

```verilog
always_ff @(posedge clk) begin
    if (rst)
        out <= 32'sd0;
    else
        out <= out + {{16{product[15]}}, product};
end
```

## Issue 2: Sign Extension Error in mac_llm_B.v

The product wire is declared unsigned so negative results are wrong.

Offending lines from mac_llm_B.v:

```verilog
wire [15:0] product;
assign product = a * b;
...
out <= out + product;
```

Why it is wrong: a and b are signed 8-bit inputs. Their product should be a signed 16-bit value. But product is declared as wire [15:0] without the signed keyword, so the multiplication result is treated as unsigned. When you add a 16-bit unsigned value to a 32-bit signed accumulator the compiler zero-extends it instead of sign-extending it. This means negative products like a=-5, b=2 give product=65526 instead of -10, which corrupts the accumulator.

Corrected version:

```verilog
wire signed [15:0] product;
assign product = a * b;
...
out <= out + {{16{product[15]}}, product};
```

The fix has two parts: declare product as signed, and explicitly sign-extend it to 32 bits using the replication operator before adding to the accumulator.

## Summary

| Issue | File | Severity | Fix |
|-------|------|----------|-----|
| always instead of always_ff | mac_llm_B.v | Medium, spec violation | Replace with always_ff |
| Unsigned product causes wrong sign | mac_llm_B.v | High, wrong arithmetic | Declare signed, add sign extension |

mac_llm_A.v (Claude Sonnet 4.6) compiled cleanly and used correct always_ff with sign extension. mac_correct.v fixes both issues and passes all 6 testbench assertions.
