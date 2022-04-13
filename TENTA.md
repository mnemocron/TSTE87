# TSTE 87 - final exam questions

---

### What is the diﬀerence between retiming and pipelining? (2P)

**Solution**: Pipelining introduces delay elements between the input and the output, while retiming just moves the existing ones around.

### What are the reasons for scaling signal levels? (Select exactly two reasons) (2P)

**Solution**: Avoid overﬂow and reduce round-oﬀ noise (increase SNR, use full dynamic range).

### What are the reasons for scheduling over more than one sample period? (Select exactly two reasons) (2P)

**Solution**: Two out of:
- To obtain a more eﬃcient resource allocation
- When the longest execution time is longer than the sample period
- If the sample period is not an integer multiple of the time unit used

### How are the iteration period bound `T∞`, minimal sample period, `Tmin`, number of operations and number of delays respectively aﬀected by unfolding an algorithm a factor N? (2P)

(guaranteed question)

**Solution**:
- Iteration period bound: increases by a factor N
- Minimal sample period: unchanged
- Number of operations: increases by a factor N
- Number of delays: unchanged

### Name two redundant number systems. (2P)

**Solution**: For example, 
- signed-digit representation 
- carry-save representation.

### Give two examples of use cases where a dedicated implementation may be advantageous compared to using general purpose DSP processors. (2P)

**Solution**:
- when there are tight limitations on energy consumption
- when manufacturing costs are lower due to a very high amount of manufactured pieces

### Deﬁne latency and execution time. (2P)

**Solution**:
- Latency: time from an input to the corresponding output.
- Exection time: time from an input to the next input.

### Name exactly two features that are typically found in general purpose DSP processors, but not in CPUs/microcontrollers. (2P)

- certain chache config?
- MACC instruction?
- DSP specific peripheral drivers (eg. I2S)

### Explain how a minimum signed-digit representation and the canonic signed-digit representation diﬀers from the general signed-digit representation. (2P)


### Name and describe one way to accelerate a carry-propagation adder. (2P)


###  Why is the latency of a bit-serial (LSB ﬁrst) multiplier at least equal to the number of fractional bits? (2P)


### Why are only the loops included when determining the minimal sample period? (And, e.g., not the critical path?) (2P) 

**Solution**: Non-recursive parts can be pipelined/retimed.

### How is the throughput (number of operations per time unit) related to the execution time? (2P)

**Solution**: Throughput = 1/execution time

### What is a redundant number representation? Give one example. (2P)

**Solution**: In a redundant number representation there is more than one representation of each number.

### The following expression shall be realized using shifts, additions and subtractions. Draw a realization using as few additions and subtractions as possible. (4P)

`y = 13 x1 − 5 x2 + 25 x3`

Note that: 25 = 5 × 5 = 13 × 2 − 1. 

**Solution**

```
y = 13 x1 − 5 x2 + 25 x3 
y = 8 x1 + 5(x1 − x2 + 5 x3) 
y = 8(x1 + 2 x3) + 5((x1 + 2 x3) − x2) − x3
```

so ﬁve additions/subtractions are required.

### A DSP algorithm is either iterative or block processing. Describe the diﬀerence and give an example of each. (2P)


### Which two methods can be used to control the timing of a circuits? That is, when things happen. (2P)


### Deﬁne latency and execution time. (2P)



