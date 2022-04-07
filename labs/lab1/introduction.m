%%
addpath /courses/TSTE87/matlab/

%% Signal flow graph
sfg = [];
sfg = addoperand(sfg, 'in', 1, 1);
sfg = addoperand(sfg, 'add', 1, [1 2], 3);
sfg = addoperand(sfg, 'delay', 1, 3, 4);
sfg = addoperand(sfg, 'constmult', 1, 4, 2, 0.5);
sfg = addoperand(sfg, 'out', 1, 4);

dotsfgplot(sfg, 'eps')

%% 1 a) 
% Give the exact value of all samples in the impulse response that are 
% larger than 0.1.
resp = impulseresponse(sfg, 128);
resp_m = resp(resp>0.1)

%% 1 b)
% What type of filter is this (lowpass, highpass, bandpass, or bandstop)?
freqz(resp)
% --> lowpass filter

%% 3 a)
% onsider the following second-order direct form II IIR filter, where 
% a0 = a2 = 57/256, a1 = 55/128, b1 = 179/512, b2 = −171/512. 
% The objective is to study the precedence
% relations, to scale the filter, and to study effects of overflow.
clear; clc;
a0 = 57/256;
a2 = 57/256;
a1 = 55/128;
b1 = 179/512;
b2 = -171/512;

% Number the nodes and operations and create the signal flow graph.
sfg = [];
sfg = addoperand(sfg, 'in', 1, 1);
sfg = addoperand(sfg, 'add', 1, [1 3], 2);
sfg = addoperand(sfg, 'delay', 1, 2, 4);
sfg = addoperand(sfg, 'delay', 2, 4, 5);
sfg = addoperand(sfg, 'constmult', 1, 4, 6, b1);
sfg = addoperand(sfg, 'constmult', 2, 5, 7, b2);
sfg = addoperand(sfg, 'constmult', 3, 4, 8, a1);
sfg = addoperand(sfg, 'constmult', 4, 5, 9, a2);
sfg = addoperand(sfg, 'constmult', 5, 2,11, a0);
sfg = addoperand(sfg, 'add', 2, [6 7], 3);
sfg = addoperand(sfg, 'add', 3, [8 9], 10);
sfg = addoperand(sfg, 'add', 4, [10 11], 12);
sfg = addoperand(sfg, 'out', 5, 12);

%errors = checknodes(sfg)
%dotsfgplot(sfg, 'eps')

%% 3 b) 
% Print and plot the precedence graph.
printprecedence(sfg)

%% 3 c)
% Simulate the filter using an impulse.
N = 64;
resp = impulseresponse(sfg, N);
%plot(resp)

random = 2*rand(1, 1024)-1;
impulse = [1, zeros(1,N-1)];
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg, impulse);

%% 3 d)  
% What is the passband edge? Amax = 1.023 dB

freqz(resp)

%[h,w] = freqz(resp);
%plot(w/pi, db(h));
%hold on
%plot([0,1], [-1.023 -1.023])

%% 3 e) 
% How large is the stopband attenuation? omega_s*T = 0.88 pi rad
% --> 40 dB

%% 3 f) 
% Plot the discrete values of all interesting nodes.

% a node is interesting if it can overflow --> outputs of adders
% 2, 3, 10, 12
plot(nodes')
grid on

%% 3 g) 
% Identify nodes that are possibly badly scaled under the safe scaling 
% criteria, i.e., critical nodes where the sum 
% of absolute node values are greater than one.

% safe scaling criterion: L1 norm of the node values if the global input
% has an impulse at the input

node_sum = sum(abs(nodes'));
display(node_sum(2))
display(node_sum(3))
display(node_sum(10))
display(node_sum(12))


%% 3 h) 
% Scale all critical nodes using safe scaling only using power-of-two 
% scaling coefficients. Indicate where you introduce scaling.

% first addtion (node 2) overflows
% scale x(n) input by 0.5
% correct output y(n) by 2
sfg_s = sfg;
sfg_s = insertoperand(sfg_s, 'constmult', 6, 1, 0.5);
sfg_s = insertoperand(sfg_s, 'constmult', 7, 12, 2.0); 
% perhaps we do now want to scale the output back by a factor of 2 
% because the node sum is 1.3388 which is out of range for [-1 ... +1]

errors = checknodes(sfg_s)
dotsfgplot(sfg_s, 'eps')

%% 3 i) 
% Simulate the filter again. Are the nodes correctly scaled? What is 
% the sum of the absolute node values in the critical nodes?
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg_s, impulse);
node_sum = sum(abs(nodes'))

%% 3 j) 
% How does scaling affect the magnitude response?
resp2 = impulseresponse(sfg_s, N);
[h,w]   = freqz(resp);
[h_s,w_s] = freqz(resp);

plot(w/pi, db(h));
hold on
grid on
plot(w_s/pi,db(h_s))
% --> no effect


%% 3 k)
% Simulate the original and scaled filters using the same random data for
% both. Use 1 integer bit and 15 fractional bits. Compare the discrete 
% outputs by plotting them in the same figure with different markers, 
% e.g.,  x’ and ’o’, respectively (use hold on to plot several plots in 
% the same figure). Comments?
clc
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg_s, impulse);

y1 = simulate(sfg,   impulse, 1, [], [], [1,15]);
y2 = simulate(sfg_s, impulse, 1, [], [], [1,15]);
r1 = simulate(sfg,   random, 1, [], [], [1,15]);
r2 = simulate(sfg_s, random, 1, [], [], [1,15]);

subplot(2,2,1)
hold on
grid on
stem(y1)
stem(y2)
title("impulse response")
legend(["unscaled (overflows)", "scaled"])

subplot(2,2,2)
hold on
grid on
plot(r1)
plot(r2)
title("random signal input")
legend(["unscaled (overflows)", "scaled"])

subplot(2,2,3)
grid on
plot(r1-r2)
title("output error for random signal input")
legend(["r_1 - r_2"])

subplot(2,2,4)
histogram(r1-r2)
title("error distribution")

%% 4 a)
% In this problem we consider a WDF based on first- and second-order 
% allpass sections using symmetric two-port adaptors as shown below. 
% The coefficients are α0 = 167/256, α1 = −135/256, α2 = 1663/2048, 
% α3 = −1493/2048, α4 = 669/1024, α5 = −117/128, α6 = 583/1024.
clear; clc;

a0 = 167/256;
a1 = -135/256;
a2 = 1663/2048;
a3 = -1493/2048;
a4 = 669/1024;
a5 = -117/128; 
a6 = 583/1024;

% Number the nodes and operations and create the signal flow graph. 
% The inputs and outputs of the symmetric two-port adaptor are related and 
% numbered as shown below. Note that the position of the adaptor 
% coefficient, α0, denotes which input to be subtracted
sfg = [];
sfg = addoperand(sfg, 'in', 1, 1);
sfg = addoperand(sfg, 'twoport', 1, [1, 4], [2, 3], a0, 'symmetric');
sfg = addoperand(sfg, 'delay', 1, 3, 4);
sfg = addoperand(sfg, 'twoport', 2, [ 1,17], [11,13], a1, 'symmetric');
sfg = addoperand(sfg, 'twoport', 3, [13,15], [16,14], a2, 'symmetric');
sfg = addoperand(sfg, 'delay', 2, 14, 15);
sfg = addoperand(sfg, 'delay', 3, 16, 17);
sfg = addoperand(sfg, 'twoport', 4, [ 2,10], [ 5, 6], a3, 'symmetric');
sfg = addoperand(sfg, 'twoport', 5, [ 6, 8], [ 9, 7], a4, 'symmetric');
sfg = addoperand(sfg, 'delay', 4,  9, 10);
sfg = addoperand(sfg, 'delay', 5,  7,  8);
sfg = addoperand(sfg, 'twoport', 6, [11,22], [23,18], a5, 'symmetric');
sfg = addoperand(sfg, 'twoport', 7, [18,20], [21,19], a6, 'symmetric');
sfg = addoperand(sfg, 'delay', 6, 21, 22);
sfg = addoperand(sfg, 'delay', 7, 19, 20);
sfg = addoperand(sfg, 'add', 1, [5 23], 24);
sfg = addoperand(sfg, 'constmult', 1, 24,25, 0.5);
sfg = addoperand(sfg, 'out', 1, 25);

coeff = [a0,a1,a2,a3,a4,a5,a6];
sfg_lwdf = sfg_LWDF(coeff);

errors = checknodes(sfg)
%dotsfgplot(sfg, 'eps')

% quickcheck with generated solution
N = 64;
out1 = impulseresponse(sfg, N);
out2 = impulseresponse(sfg_lwdf, N);
plot(out2); hold on; plot(out1); legend

%% 4 b)
% Simulate the filter using an impulse and check the values of all 
% interesting nodes. Comments?
N = 256;
random = 2*rand(1, 1024)-1;
impulse = [1, zeros(1,N-1)];
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg, impulse);

node_sum = sum(abs(nodes'))

%% 4 c)
% Plot the phase-response of the two allpass branches in the same plot.
% The command angle determines the phase of the frequency response, 
% which can be obtained as output from freqz. Alternatively, phasez can be 
% used to directly obtain the phase response from the impulse response.

%% 4 d)
% How large is the difference in phase in the pass- and stopband?


%% 4 e)
% Scale the filter using L2-scaling (only use power-of-two scaling 
% coefficients). Indicate where you introduce scaling. Note that all four 
% sections should have as large dynamic range as possible.


%% 4 f)
% Simulate the scaled filter. What is the value of the L2-sum in the 
% different nodes? Are the nodes correctly scaled? How can you verify that 
% the filter function is not changed?

[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg_s, impulse);
node_sum = sum(abs(nodes'))

% verify filter function
out1 = impulseresponse(sfg, N);
out2 = impulseresponse(sfg_s, N);
[h1,w1] = freqz(out1);
[h2,w2] = freqz(out2);

plot(w1/pi, db(h1));
hold on
grid on
plot(w2/pi,db(h2))

%% 4 g)
% Simulate the scaled filter with a random input. Comments? Can overflow 
% occur in any node?
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg_s, random);

%% 4 h)
% Introduce a pipelining delay in each branch and compare the output with 
% the non-pipelined SFG. Comments?


%% 4 i)
% Plot the precedence graph for the pipelined SFG.
printprecedence(sfg_p)

%% 4 j)
% Flatten the SFG and plot the precedence graph.

sfg_f = flattensfg(sfg_p);
printprecedence(sfg_f)


