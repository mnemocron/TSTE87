
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
clear all; clc;
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

%% 1 a) Simulate the impulse response 

resp_ap = impulseresponse(sfga, 32);

% first upsampler
resp_up1 = upsample(resp_ap, 2);
% first interpolation filter
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfgb, resp_up1);
resp_int1 = nodes(23,:);

% second upsampler
resp_up2 = upsample(resp_int1, 2);
% second interpolation filter
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfgb, resp_up2);
resp_int2 = nodes(23,:);

% hold on;
% % stem(resp_ap)
% % stem(resp_up1)
% stem(resp_int1)
% % stem(resp_up2)
% stem(resp_int2)
% grid on
% legend(["1^{st} stage", "full interpolator"])

%% 1 b) Plot Frequency response
[h1,w1]   = freqz(resp_int1);
[h2,w2]   = freqz(resp_int1);

plot(w1/pi, db(h1));
hold on
grid on
plot(w2/pi,db(h2))

%% 1 c What is the passband edge

%% 1 d) Quantize coefficients
Wf = 11; % fractional bits
sfga_q = sfga;
sfgb_q = sfgb;

sfga_q(2:8,7) = quant(sfga_q(2:8,7), 2^-Wf);
sfgb_q(2:6,7) = quant(sfgb_q(2:6,7), 2^-Wf);

%% 1 e) How does 

resp_ap_q = impulseresponse(sfga_q, 32);

% first upsampler
resp_up1_q = upsample(resp_ap_q, 2);
% first interpolation filter
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfgb_q, resp_up1_q);
resp_int1_q = nodes(23,:);

% second upsampler
resp_up2_q = upsample(resp_int1_q, 2);
% second interpolation filter
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfgb_q, resp_up2_q);
resp_int2_q = nodes(23,:);

[h1q,w1q]   = freqz(resp_int1_q);
[h2q,w2q]   = freqz(resp_int1_q);

plot(w2/pi, db(h2));
hold on
grid on
plot(w2q/pi,db(h2q))

% --> stopband ripple

%% 1 f) Simulate random data
N = 16;
random = 2*rand(1, N)-1;
% quantized or not? --> yes

% first upsampler
resp_rand_up1 = upsample(random, 2);
% first interpolation filter
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfgb_q, resp_rand_up1);
resp_rand_int1 = nodes(23,:);

% second upsampler
resp_rand_up2 = upsample(resp_rand_int1, 2);
% second interpolation filter
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfgb_q, resp_rand_up2);
resp_rand_int2 = nodes(23,:);

%% 1 g) Plot delay values

add_ins = [10 22];
del_ids = [2 4 5 8 9];

subplot(1,2,1)
stem(nodes(add_ins, :)')
title("adder inputs")

subplot(1,2,2)
stem(nodes(del_ids(1), :)')
title("one delay stage")

% Comment
% every other sample in the adder inputs is 0
% can replace adder with a multiplexing switch

%% 1 h) Adaptor operations per second



%% 2 a) 
% cascading H_A and the first H_0
% the second H_0 cannot be cascaded, 
% so run 2 simulation steps instead of 3
sfgc_q = cascadesfg(sfga_q, sfgb_q);

%% b) simulate impulse response

resp_dr_q = impulseresponse(sfgc_q, 64);

% second upsampler
resp_up3_q = upsample(resp_dr_q, 2);
% second interpolation filter
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfgb_q, resp_up3_q);
resp_int3_q = nodes(23,:);

[h1q,w1q]   = freqz(resp_int1_q);
[h2q,w2q]   = freqz(resp_int1_q);

plot(w2/pi, db(h2));
hold on
grid on
plot(w2q/pi,db(h2q))























