
addpath /courses/TSTE87/matlab/
% addpath ../../../newasictoolbox/

%%
% the full upsampler has an Allpass filter first, 
% followed by two interpolator filters H0
%
% [ H_AP ] --> UP2 --> [ H_0 ] --> UP2 --> [ H_AP ]
%
% This file is the Allpass filter
% start here

%%
clear all; clc; close all;
format shorteng

N = 128;
impulse = [1, zeros(1,N-1)];
random = 2*rand(1,N)-1;

% The phase-correcting allpass filter
% Adaptor coefficients
a10 = 0.4573;
a11 = -0.2098;
a12 = 0.5695;
a13 = -0.2123;
a14 = 0.0952;
a15 = -0.2258;
a16 = -0.4490;

sfga = [];

sfga = addoperand(sfga, 'in', 1, 1);
sfga = addoperand(sfga, 'twoport', 1, [ 1  3], [ 4  2], a10, 'symmetric');
sfga = addoperand(sfga, 'twoport', 2, [ 4  9], [10  5], a11, 'symmetric');
sfga = addoperand(sfga, 'twoport', 3, [ 6  8], [ 9  7], a12, 'symmetric');
sfga = addoperand(sfga, 'twoport', 4, [10 15], [16 11], a13, 'symmetric');
sfga = addoperand(sfga, 'twoport', 5, [12 14], [15 13], a14, 'symmetric');
sfga = addoperand(sfga, 'twoport', 6, [16 21], [22 17], a15, 'symmetric');
sfga = addoperand(sfga, 'twoport', 7, [18 20], [21 19], a16, 'symmetric');
sfga = addoperand(sfga, 'delay', 1,  2,  3);
sfga = addoperand(sfga, 'delay', 2,  5,  6);
sfga = addoperand(sfga, 'delay', 3,  7,  8);
sfga = addoperand(sfga, 'delay', 4, 11, 12);
sfga = addoperand(sfga, 'delay', 5, 13, 14);
sfga = addoperand(sfga, 'delay', 6, 17, 18);
sfga = addoperand(sfga, 'delay', 7, 19, 20);
sfga = addoperand(sfga, 'out', 1, 22);

% Bireciprocal low-pass filter for interpolator
% Adaptor coefficients (all even coefficients are zero)
a1 = -0.068129;
a3 = -0.242429;
a5 = -0.461024;
a7 = -0.678715;
a9 = -0.888980;

sfgb = [];

sfgb = addoperand(sfgb, 'in', 1, 1);
sfgb = addoperand(sfgb, 'twoport', 1, [2 5], [6 3], a3, 'symmetric');
sfgb = addoperand(sfgb, 'twoport', 2, [6 9], [10 7], a7, 'symmetric');
sfgb = addoperand(sfgb, 'twoport', 3, [1 13], [14 11], a1, 'symmetric');
sfgb = addoperand(sfgb, 'twoport', 4, [14 17], [18 15], a5, 'symmetric');
sfgb = addoperand(sfgb, 'twoport', 5, [18 21], [22 19], a9, 'symmetric');
sfgb = addoperand(sfgb, 'delay', 1, 1, 2);
sfgb = addoperand(sfgb, 'delay', 2, 3, 4);
sfgb = addoperand(sfgb, 'delay', 3, 4, 5);
sfgb = addoperand(sfgb, 'delay', 4, 7, 8);
sfgb = addoperand(sfgb, 'delay', 5, 8, 9);
sfgb = addoperand(sfgb, 'delay', 6, 11, 12);
sfgb = addoperand(sfgb, 'delay', 7, 12, 13);
sfgb = addoperand(sfgb, 'delay', 8, 15, 16);
sfgb = addoperand(sfgb, 'delay', 9, 16, 17);
sfgb = addoperand(sfgb, 'delay', 10, 19, 20);
sfgb = addoperand(sfgb, 'delay', 11, 20, 21);
sfgb = addoperand(sfgb, 'add', 1, [10 22], 23);
sfgb = addoperand(sfgb, 'out', 1, 23);

%% 1 a) 
% Simulate the impulse response for the complete interpolator ﬁlter. 
% Use the function upsample in MATLAB to expand the signal (insert zeros)

[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga, impulse);
input2 = upsample(output1,2);
[output2,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb, input2);
input3 = upsample(output2,2);
[output3,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgb, input3);

%% 1 b) 
% Plot the frequency response both for the signal after the ﬁrst 
% interpolator stage and for the complete interpolator ﬁlter.
[h1,w1]   = freqz(output1);
[h2,w2]   = freqz(output2);
[h3,w3]   = freqz(output3);

figure
plot(w2/pi, db(h2));
hold on
grid on
plot(w3/pi,db(h3))
legend(["2x upsampled", "4x upsampled"])
ylim([-200 50]);
title("Task 1 b) frequency response")
% todo xaxis
% legend(["H_{AP} + H_0", "H_{AP} + H_0 + H_0"])

%% 1 c) What is the passband edge for these two cases?

passbandedge2 = w2(find(db(h2) < max(db(h2))-3,1))/pi
passbandedge3 = w3(find(db(h3) < max(db(h3))-3,1))/pi

%% 1 d) 
% Quantize the adaptor coeﬃcients to 11 fractional bits 
% and plot the frequency response. 
Wf = 11; % fractional bits
sfga_q = sfga;
sfgb_q = sfgb;

% modify the sfg directly at the positions where the coefficients are
% stored

% sfga_q(2:8,7) = quant(sfga_q(2:8,7), 2^-Wf);  % Deep Learning Toolbox
% sfgb_q(2:6,7) = quant(sfgb_q(2:6,7), 2^-Wf);
sfga_q(2:8,7) = round(sfga_q(2:8,7) .* 2^Wf) .* 2^-Wf;
sfgb_q(2:6,7) = round(sfgb_q(2:6,7) .* 2^Wf) .* 2^-Wf;

%% 1 e) How does quantization aﬀect the magnitude response?

[output1q,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga_q, impulse);
input2q = upsample(output1q,2);
[output2q,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb_q, input2q);
input3q = upsample(output2q,2);
[output3q,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgb_q, input3q);

[h1q,w1q]   = freqz(output1q);
[h2q,w2q]   = freqz(output2q);
[h3q,w3q]   = freqz(output3q);

figure
plot(w2/pi, db(h2), '--');
hold on
grid on
plot(w3/pi, db(h3), '--');
plot(w2q/pi,db(h2q));
plot(w3q/pi,db(h3q));
title("Task 1 e) effect of quantization on magn response")
legend(["2x upsampled", "4x upsampled", "2x upsampled (quantized)", "4x upsampled (quantized)"])
% legend(["H_{AP} + H_0", "H_{AP} + H_0 + H_0"])

% --> stopband ripple

%% 1 f) 
% Simulate the complete interpolator ﬁlter using a random signal and save
% both the input and output data. These signals will be used for reference 
% at later design iterations.
N = 16;
random = 2*rand(1, N)-1;

[output1r,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga_q, random);
input2r = upsample(output1r,2);
[output2r,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb_q, input2r);
input3r = upsample(output2r,2);
[output3r,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgb_q, input3r);

%% 1 g) 
% Plot the discrete delay element values for one of the delays in the last 
% stage bireciprocal ﬁlter and for the discrete inputs to the adder in the 
% last stage bireciprocal ﬁlter. Comments?

add_ins = [10 22];
del_ids = [2 4 5 8 9];

figure
subplot(1,2,1)
stem(nodes3(add_ins, :)')
title("Task 1g) plot adder inputs")
grid on

subplot(1,2,2)
stem(nodes3(del_ids(1), :)')
title("Task 1g) plot one delay stage")
grid on

% Comment
% every other sample in the adder inputs is 0
% can replace adder with a multiplexing switch

%% 1 h) 
% Determine the number of adaptor operations required per second.

% H_AP has 7 twoports 
% H_0 has 5 twoports
N_op_1 = 1.6e6 * 7 + 2*1.6e6 * 5 + 4*1.6e6 * 5
% 59.2 Mega-operations per second

%% 2 a) 
% As an intermediate design iteration we will apply polyphase decomposition 
% to the bireciprocal ﬁlters. This results in the ﬁlter structure below. 
% Now there are only two different sample rates, as the allpass ﬁlter and 
% the ﬁrst bireciprocal ﬁlter runs at the same sample rate. 
% Remember to use the quantized coeﬃcients.

% Create the SFG. This can, e.g., be done by modifying the SFG:s used in Task 1.
% Create new SFG, note that:
% - delay v0 is missing
% - adder at the output is missing
% - instead, 2 new outputs are present

% Quantized coeffs
Wf = 11;
a1 = round(a1 .* 2^Wf) .* 2^-Wf;
a3 = round(a3 .* 2^Wf) .* 2^-Wf;
a5 = round(a5 .* 2^Wf) .* 2^-Wf;
a7 = round(a7 .* 2^Wf) .* 2^-Wf;
a9 = round(a9 .* 2^Wf) .* 2^-Wf;

sfgb_c = [];

sfgb_c = addoperand(sfgb_c, 'in', 1, 1);
sfgb_c = addoperand(sfgb_c, 'twoport', 1, [1 3], [4 2], a3, 'symmetric');
sfgb_c = addoperand(sfgb_c, 'twoport', 2, [4 6], [7 5], a7, 'symmetric');
sfgb_c = addoperand(sfgb_c, 'twoport', 3, [1 9], [10 8], a1, 'symmetric');
sfgb_c = addoperand(sfgb_c, 'twoport', 4, [10 12], [13 11], a5, 'symmetric');
sfgb_c = addoperand(sfgb_c, 'twoport', 5, [13 15], [16 14], a9, 'symmetric');
sfgb_c = addoperand(sfgb_c, 'delay', 1, 2, 3);
sfgb_c = addoperand(sfgb_c, 'delay', 2, 5, 6);
sfgb_c = addoperand(sfgb_c, 'delay', 3, 8, 9);
sfgb_c = addoperand(sfgb_c, 'delay', 4, 11, 12);
sfgb_c = addoperand(sfgb_c, 'delay', 5, 14, 15);
sfgb_c = addoperand(sfgb_c, 'out', 1, 7);
sfgb_c = addoperand(sfgb_c, 'out', 2, 16);


% plotprecedence(sfgb2);

%% 2 b) impulse response
% Simulate the impulse response and using your reference signal to validate 
% that the ﬁlter has the same function as the ﬁrst design iteration. 
% To interleave signals you can use reshape. Note that it is important to 
% take the ﬁrst value from the correct branch. 

% "cascading" is still done by using 3 simulation steps for the 3 filters
clc
[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga_q, impulse);
[output2,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb_c, output1);
% instead of upsampling, do interleaving of adder inputs:
input3 = reshape([output2(2,:);output2(1,:)],1,2*length(output2(2,:)));
[output3,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgb_c, input3);
% instead of upsampling, do interleaving of adder inputs:
output4 = reshape([output3(2,:);output3(1,:)],1,2*length(output3(2,:)));

[h4c,w4c]   = freqz(output4);

figure
plot(w3q/pi, db(h3q), '--');
hold on
grid on
plot(w4c/pi,db(h4c));
title("Task 1 e) effect of quantization on magn response")
legend(["4x upsampled (quantized)", "4x upsampled (commutated)"])

% figure
% stem(output3q); 
% hold on;
% grid on;
% stem(output4); 
% legend(["original 4x upsampled", "commutaded 4x upsampled"])
% title("Task 2 b) Simulate commutated SFG")

%% 2 c) 
% Determine the number of adaptor operations required per second.

N_op_2 = 1.6e6 * 7 + 1.6e6 * 5 + 2*1.6e6 * 5
N_op_2 / N_op_1
% 35.2 Mega-operations per second
% --> 40% less adaptor operations per second

%% Task 3
% Finally, we will realize a single rate version of the interpolator. 
% This is shown in the figure below. This is also the SFG to be used 
% for subsequent laboratory works.

% (the following includeds all coefficients and SFG's again to quickly 
% copy for future labs)

% Coefficients
a1 = -0.068129;
a3 = -0.242429;
a5 = -0.461024;
a7 = -0.678715;
a9 = -0.888980;
a10 = 0.4573;
a11 = -0.2098;
a12 = 0.5695;
a13 = -0.2123;
a14 = 0.0952;
a15 = -0.2258;
a16 = -0.4490;

% Quantized Coefficients
Wf = 11;
a1 = round(a1 .* 2^Wf) .* 2^-Wf;
a3 = round(a3 .* 2^Wf) .* 2^-Wf;
a5 = round(a5 .* 2^Wf) .* 2^-Wf;
a7 = round(a7 .* 2^Wf) .* 2^-Wf;
a9 = round(a9 .* 2^Wf) .* 2^-Wf;
a10 = round(a10 .* 2^Wf) .* 2^-Wf;
a11 = round(a11 .* 2^Wf) .* 2^-Wf;
a12 = round(a12 .* 2^Wf) .* 2^-Wf;
a13 = round(a13 .* 2^Wf) .* 2^-Wf;
a14 = round(a14 .* 2^Wf) .* 2^-Wf;
a15 = round(a15 .* 2^Wf) .* 2^-Wf;
a16 = round(a16 .* 2^Wf) .* 2^-Wf;

sfga = [];

sfga = addoperand(sfga, 'in', 1, 1);
sfga = addoperand(sfga, 'twoport', 1, [ 1  3], [ 4  2], a10, 'symmetric');
sfga = addoperand(sfga, 'twoport', 2, [ 4  9], [10  5], a11, 'symmetric');
sfga = addoperand(sfga, 'twoport', 3, [ 6  8], [ 9  7], a12, 'symmetric');
sfga = addoperand(sfga, 'twoport', 4, [10 15], [16 11], a13, 'symmetric');
sfga = addoperand(sfga, 'twoport', 5, [12 14], [15 13], a14, 'symmetric');
sfga = addoperand(sfga, 'twoport', 6, [16 21], [22 17], a15, 'symmetric');
sfga = addoperand(sfga, 'twoport', 7, [18 20], [21 19], a16, 'symmetric');
sfga = addoperand(sfga, 'delay', 1,  2,  3);
sfga = addoperand(sfga, 'delay', 2,  5,  6);
sfga = addoperand(sfga, 'delay', 3,  7,  8);
sfga = addoperand(sfga, 'delay', 4, 11, 12);
sfga = addoperand(sfga, 'delay', 5, 13, 14);
sfga = addoperand(sfga, 'delay', 6, 17, 18);
sfga = addoperand(sfga, 'delay', 7, 19, 20);
sfga = addoperand(sfga, 'out', 1, 22);

sfgb = [];

sfgb = addoperand(sfgb, 'in', 1, 1);
sfgb = addoperand(sfgb, 'twoport', 1, [1 3], [4 2], a3, 'symmetric');
sfgb = addoperand(sfgb, 'twoport', 2, [4 6], [7 5], a7, 'symmetric');
sfgb = addoperand(sfgb, 'twoport', 3, [1 9], [10 8], a1, 'symmetric');
sfgb = addoperand(sfgb, 'twoport', 4, [10 12], [13 11], a5, 'symmetric');
sfgb = addoperand(sfgb, 'twoport', 5, [13 15], [16 14], a9, 'symmetric');
sfgb = addoperand(sfgb, 'delay', 1, 2, 3);
sfgb = addoperand(sfgb, 'delay', 2, 5, 6);
sfgb = addoperand(sfgb, 'delay', 3, 8, 9);
sfgb = addoperand(sfgb, 'delay', 4, 11, 12);
sfgb = addoperand(sfgb, 'delay', 5, 14, 15);
sfgb = addoperand(sfgb, 'out', 1, 7);
sfgb = addoperand(sfgb, 'out', 2, 16);

% unfolding transformed filter
sfgc = [];

sfgc = addoperand(sfgc, 'in', 1, 7);
sfgc = addoperand(sfgc, 'in', 2, 16);
sfgc = addoperand(sfgc,'twoport',13,[16 17],[18 19],a1,'symmetric');
sfgc = addoperand(sfgc,'twoport',14,[18 20],[21 22],a5,'symmetric');
sfgc = addoperand(sfgc,'twoport',15,[21 23],[24 25],a9,'symmetric');
sfgc = addoperand(sfgc,'twoport',16,[16 26],[27 28],a3,'symmetric');
sfgc = addoperand(sfgc,'twoport',17,[27 29],[30 31],a7,'symmetric');
sfgc = addoperand(sfgc,'twoport',18,[7 19],[32 33],a1,'symmetric');
sfgc = addoperand(sfgc,'twoport',19,[32 22],[34 35],a5,'symmetric');
sfgc = addoperand(sfgc,'twoport',20,[34 25],[36 37],a9,'symmetric');
sfgc = addoperand(sfgc,'twoport',21,[7 28],[38 39],a3,'symmetric');
sfgc = addoperand(sfgc,'twoport',22,[38 31],[40 41],a7,'symmetric');
sfgc = addoperand(sfgc, 'delay', 1, 33, 17);
sfgc = addoperand(sfgc, 'delay', 2, 35, 20);
sfgc = addoperand(sfgc, 'delay', 3, 37, 23);
sfgc = addoperand(sfgc, 'delay', 4, 39, 26);
sfgc = addoperand(sfgc, 'delay', 5, 41, 29);
sfgc = addoperand(sfgc, 'out', 1, 24);
sfgc = addoperand(sfgc, 'out', 2, 30);
sfgc = addoperand(sfgc, 'out', 3, 36);
sfgc = addoperand(sfgc, 'out', 4, 40);

%% 3 b)
% Simulate the impulse response and using your reference signal to 
% validate that the ﬁlter has the same function as the ﬁrst design 
% iteration. Save the output from the impulse response simulation, 
% to be used in the ﬁnal question.
clc
[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga, impulse);
[output2,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb, output1);
[output3,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgc, output2, [1;2]);
output4 = reshape([ ...
    getnodevalues(output3,outputids3,1); ...
    getnodevalues(output3,outputids3,2); ...
    getnodevalues(output3,outputids3,3); ...
    getnodevalues(output3,outputids3,4)], ...
    1,4*length(output3(2,:)));

[h5,w5] = freqz(output4);
figure
plot(w4c/pi,db(h4c),'DisplayName','Commutated');
hold on;
grid on;
plot(w5/pi,db(h5),'DisplayName','Unfolded');
legend('show');
ylim([-200 50]);

%% 3 c)
% Determine the number of adaptor operations required per second.
N_op_3 = 1.6e6 * 7 + 1.6e6 * 5 + 1.6e6 * 10
N_op_3 / N_op_1
% --> 40% less adaptor operations per second

%% 3 d) 
% Plot the precedence graph of the ﬁlter. How many two-port operations are 
% there in the critical path?

% plotprecedence(sfga);
% plotprecedence(sfgb);
% plotprecedence(sfgc);

sfg_cas = cascadesfg(sfgb, sfgc);
sfg_cas = cascadesfg(sfga, sfg_cas);
% plotprecedence(sfg_cas);

[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfg_cas, impulse);
output4=reshape([getnodevalues(output1,outputids1,1);getnodevalues(output1,outputids1,2);getnodevalues(output1,outputids1,3);getnodevalues(output1,outputids1,4)],1,4*length(output1(2,:)));
[h6,w6] = freqz(output4);
figure
plot(w5/pi,db(h5),'DisplayName','Commutated');
hold on;
plot(w6/pi,db(h6),'DisplayName','Unfolded');
hold off;
legend('show');
ylim([-200 50]);

%% 3 e)
% Introduce pipelining such that the critical path is at most three 
% adaptors. Mark in the ﬁgure where delays are introduced. Check by 
% plotting the precedence graph.


%% 3 f)
% Simulate the impulse response for the pipelined ﬁlter. Compare the phase 
% response with the non-pipelined design by plotting both in the same 
% ﬁgure. Comments?





