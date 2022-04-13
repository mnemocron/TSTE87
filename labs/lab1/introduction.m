%%

% addpath /courses/TSTE87/matlab/
addpath ../../../newasictoolbox/

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
N = 128;
resp = impulseresponse(sfg, N);
%plot(resp)

random = 2*rand(1, 1024)-1;
impulse = [1, zeros(1,N-1)];
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg, impulse);

%% 3 d)  
% What is the passband edge? Amax = 1.023 dB

freqz(resp)
% 0.4 * pi

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
plot(nodes([2,3,10,12],:)')
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
sfg = addoperand(sfg, 'twoport', 2, [ 1,16], [11,12], a1, 'symmetric');
sfg = addoperand(sfg, 'twoport', 3, [12,14], [15,13], a2, 'symmetric');
sfg = addoperand(sfg, 'delay', 2, 13, 14);
sfg = addoperand(sfg, 'delay', 3, 15, 16);
sfg = addoperand(sfg, 'twoport', 4, [ 2,10], [ 5, 6], a3, 'symmetric');
sfg = addoperand(sfg, 'twoport', 5, [ 6, 8], [ 9, 7], a4, 'symmetric');
sfg = addoperand(sfg, 'delay', 4,  9, 10);
sfg = addoperand(sfg, 'delay', 5,  7,  8);
sfg = addoperand(sfg, 'twoport', 6, [11,21], [22,17], a5, 'symmetric');
sfg = addoperand(sfg, 'twoport', 7, [17,19], [20,18], a6, 'symmetric');
sfg = addoperand(sfg, 'delay', 6, 20, 21);
sfg = addoperand(sfg, 'delay', 7, 18, 19);
sfg = addoperand(sfg, 'add', 1, [5 22], 23);
sfg = addoperand(sfg, 'constmult', 1, 23,24, 0.5);
sfg = addoperand(sfg, 'out', 1, 24);

coeff = [a0,a1,a2,a3,a4,a5,a6];
sfg_lwdf = sfg_LWDF(coeff);

errors = checknodes(sfg)
%dotsfgplot(sfg, 'eps')

% quickcheck with generated solution
N = 64;
out1 = impulseresponse(sfg, N);
out2 = impulseresponse(sfg_lwdf, N);
plot(out2); hold on; grid on;
plot(out1); 
legend(["original","lwdf"])

%% 4 b)
% Simulate the filter using an impulse and check the values of all 
% interesting nodes. Comments?

% Interesting nodes = outputs of adders
% the internal adder is not of interest because it is a subtraction
% (is this correct? it could still overflow, right?)
N = 256;
random = 2*rand(1, 1024)-1;
impulse = [1, zeros(1,N-1)];
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg, impulse);

node_sum = sqrt(sum(abs(nodes').^2));

interest = [2,3,5,6,7,9,11,12,13,15,17,22,18,20];
display(node_sum(interest))
% all nodes are unsafe from overflowing because all are >1.0

% overflows at
% node 6,7,9,12,15,17,18,20


%% 4 c)
% Plot the phase-response of the two allpass branches in the same plot.
% The command angle determines the phase of the frequency response, 
% which can be obtained as output from freqz. Alternatively, phasez can be 
% used to directly obtain the phase response from the impulse response.

resp_upper = nodes( 5,:);
resp_lower = nodes(22,:);

%hold on; grid on
%stem(resp_upper)
%stem(resp_lower)
%legend(["upper allpass", "lower allpass"])

w_up = phasez(resp_upper);
w_lo = phasez(resp_lower);
[h,w] = freqz(nodes(24,:));

ang = linspace(0,1,512);

subplot(1,3,1)
hold on; grid on
plot(ang, w_up./pi.*180)
plot(ang, w_lo./pi.*180)
title("Phase Response")
xlabel("Normalized Frequency (x \pi rad/sample)")
ylabel("Phase (deg)")
legend(["upper allpass", "lower allpass"])

subplot(1,3,2)
plot(w/pi, db(h))
grid on
title("Magnitude Response")
legend("y(n)")
xlabel("Normalized Frequency (x \pi rad/sample)")
ylabel("Magnitude (dB)")

subplot(1,3,3)
plot(ang, (w_up-w_lo)./pi.*180)
grid on
title("Difference in Phase Response")
xlabel("Normalized Frequency (x \pi rad/sample)")
ylabel("Phase (deg)")


%% 4 d)
% How large is the difference in phase in the pass- and stopband?

% exactly 180 degrees or pi radians, the sum of the two allpasses cancel
% each other out

%% 4 e)
% Scale the filter using L2-scaling (only use power-of-two scaling 
% coefficients). Indicate where you introduce scaling. Note that all four 
% sections should have as large dynamic range as possible.

% overflows at
% node 6,7,9,12,15,17,18,20

sfg_s = sfg;
sfg_s = insertoperand(sfg_s, 'constmult', 2, 2, 2^-2); % node 6 overflows --> scale at node 2
sfg_s = insertoperand(sfg_s, 'constmult', 3, 5, 2^2);    % correct 6 rescale

sfg_s = insertoperand(sfg_s, 'constmult', 4, 1, 0.5);  % node 15 overflows
sfg_s = insertoperand(sfg_s, 'constmult', 5, 2, 2);    % correct node 15 rescale
sfg_s = insertoperand(sfg_s, 'constmult', 5, 11, 2);   % correct node 15 rescale

sfg_s = insertoperand(sfg_s, 'constmult', 6, 11, 2^-3);  % node 17 overflows
sfg_s = insertoperand(sfg_s, 'constmult', 7, 22, 2^3);    % correct node 17 rescale

errors = checknodes(sfg)


%dotsfgplot(sfg_s, 'eps')
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg_s, impulse);
node_sum = sqrt(sum(abs(nodes').^2));
interest = [2,3,5,6,7,9,11,12,13,15,17,22,18,20];
display(node_sum(interest))

%% 4 f)
% Simulate the scaled filter. What is the value of the L2-sum in the 
% different nodes? Are the nodes correctly scaled? How can you verify that 
% the filter function is not changed?

[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg_s, impulse);
node_sum = sqrt(sum(abs(nodes').^2))  % L2 norm!

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

y0 = simulate(sfg,   impulse);
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

figure()
[h1,w1] = freqz(y0);
[h2,w2] = freqz(y2);

plot(w1/pi, db(h1));
hold on
grid on
plot(w2/pi,db(h2))
title("Magnitude Response")
legend(["unscaled float64", "scaled sfix16"])

%% 4 h)
% Introduce a pipelining delay in each branch and compare the output with 
% the non-pipelined SFG. Comments?

sfg_p = sfg_s;
sfg_p = insertoperand(sfg_p, 'delay', 8, 2); 
sfg_p = insertoperand(sfg_p, 'delay', 9, 11); 

errors = checknodes(sfg)

y0 = simulate(sfg,   impulse);
y1 = simulate(sfg_s,   impulse, 1, [], [], [1,15]);
y2 = simulate(sfg_p, impulse, 1, [], [], [1,15]);
r1 = simulate(sfg_s,   random, 1, [], [], [1,15]);
r2 = simulate(sfg_p, random, 1, [], [], [1,15]);

subplot(1,2,1)
[h0,w0] = freqz(y0);
[h1,w1] = freqz(y1);
[h2,w2] = freqz(y2);

w_0 = phasez(y0);
w_s = phasez(y1);
w_p = phasez(y2);

plot(w0/pi, db(h0));
hold on; grid on
plot(w1/pi,db(h1))
plot(w2/pi,db(h2))
title("Magnitude Response")
legend(["unscaled float64", "scaled sfix16", "scaled & pipelined sfix16"])

subplot(1,2,2)
hold on; grid on
plot(ang, w_0./pi.*180)
plot(ang, w_s./pi.*180)
plot(ang, w_p./pi.*180)
title("Phase Response")
xlabel("Normalized Frequency (x \pi rad/sample)")
ylabel("Phase (deg)")
legend(["unscaled float64", "scaled sfix16", "scaled & pipelined sfix16"])

% Todo: comments? is this even correct?

%% 4 i)
% Plot the precedence graph for the pipelined SFG.
printprecedence(sfg_p)

%% 4 j)
% Flatten the SFG and plot the precedence graph.

sfg_f = flattensfg(sfg_p);
printprecedence(sfg_f)


