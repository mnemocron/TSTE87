clc;clear;close all;
% addpath /site/edu/da/TSTE87/matlab/

% INPUTS
N = 5000;
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
a16 = -0.449;

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


%% TASK 1
%load('interpolatorallpass.m');
%load interpolatorbireciprocal.m;

%cascadedsfg = cascadesfg(sfga, sfgb);

% Simulate
[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga, impulse);
input2 = upsample(output1,2); %Upsample by 2
[output2,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb, input2);
input3 = upsample(output2,2); %Upsample by 2
[output3,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgb, input3);

%figure;
%stem(output1);
%hold on;
%stem(input2);

%Freq respons
[h1,w1] = freqz(output1);
[h2,w2] = freqz(output2);
%figure
%plot(w1/pi, db(h1));

[h3,w3] = freqz(output3);
figure
plot(w2/pi,db(h2),'DisplayName','Filter1');
hold on;
plot(w3/pi,db(h3),'DisplayName','Filter2');
hold off;
legend('show');
ylim([-200 50]);
%%
% Quantized coeffs
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

sfga_q = [];

sfga_q = addoperand(sfga_q, 'in', 1, 1);
sfga_q = addoperand(sfga_q, 'twoport', 1, [ 1  3], [ 4  2], a10, 'symmetric');
sfga_q = addoperand(sfga_q, 'twoport', 2, [ 4  9], [10  5], a11, 'symmetric');
sfga_q = addoperand(sfga_q, 'twoport', 3, [ 6  8], [ 9  7], a12, 'symmetric');
sfga_q = addoperand(sfga_q, 'twoport', 4, [10 15], [16 11], a13, 'symmetric');
sfga_q = addoperand(sfga_q, 'twoport', 5, [12 14], [15 13], a14, 'symmetric');
sfga_q = addoperand(sfga_q, 'twoport', 6, [16 21], [22 17], a15, 'symmetric');
sfga_q = addoperand(sfga_q, 'twoport', 7, [18 20], [21 19], a16, 'symmetric');
sfga_q = addoperand(sfga_q, 'delay', 1,  2,  3);
sfga_q = addoperand(sfga_q, 'delay', 2,  5,  6);
sfga_q = addoperand(sfga_q, 'delay', 3,  7,  8);
sfga_q = addoperand(sfga_q, 'delay', 4, 11, 12);
sfga_q = addoperand(sfga_q, 'delay', 5, 13, 14);
sfga_q = addoperand(sfga_q, 'delay', 6, 17, 18);
sfga_q = addoperand(sfga_q, 'delay', 7, 19, 20);
sfga_q = addoperand(sfga_q, 'out', 1, 22);


sfgb_q = [];

sfgb_q = addoperand(sfgb_q, 'in', 1, 1);
sfgb_q = addoperand(sfgb_q, 'twoport', 1, [2 5], [6 3], a3, 'symmetric');
sfgb_q = addoperand(sfgb_q, 'twoport', 2, [6 9], [10 7], a7, 'symmetric');
sfgb_q = addoperand(sfgb_q, 'twoport', 3, [1 13], [14 11], a1, 'symmetric');
sfgb_q = addoperand(sfgb_q, 'twoport', 4, [14 17], [18 15], a5, 'symmetric');
sfgb_q = addoperand(sfgb_q, 'twoport', 5, [18 21], [22 19], a9, 'symmetric');
sfgb_q = addoperand(sfgb_q, 'delay', 1, 1, 2);
sfgb_q = addoperand(sfgb_q, 'delay', 2, 3, 4);
sfgb_q = addoperand(sfgb_q, 'delay', 3, 4, 5);
sfgb_q = addoperand(sfgb_q, 'delay', 4, 7, 8);
sfgb_q = addoperand(sfgb_q, 'delay', 5, 8, 9);
sfgb_q = addoperand(sfgb_q, 'delay', 6, 11, 12);
sfgb_q = addoperand(sfgb_q, 'delay', 7, 12, 13);
sfgb_q = addoperand(sfgb_q, 'delay', 8, 15, 16);
sfgb_q = addoperand(sfgb_q, 'delay', 9, 16, 17);
sfgb_q = addoperand(sfgb_q, 'delay', 10, 19, 20);
sfgb_q = addoperand(sfgb_q, 'delay', 11, 20, 21);
sfgb_q = addoperand(sfgb_q, 'add', 1, [10 22], 23);
sfgb_q = addoperand(sfgb_q, 'out', 1, 23);


% NEW SIM
[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga_q, impulse);
input2 = upsample(output1,2); %Upsample by 2
[output2,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb_q, input2);
input3 = upsample(output2,2); %Upsample by 2
[output3,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgb_q, input3);

[h22,w22] = freqz(output2);
%figure
%plot(w1/pi, db(h1));

[h32,w32] = freqz(output3);
figure
plot(w3/pi,db(h3),'DisplayName','original');
hold on;
plot(w32/pi,db(h32),'DisplayName','Quantized');
hold off;
legend('show');
ylim([-200 50]);

% Random input signal
[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga_q, random);
input2 = upsample(output1,2); %Upsample by 2
[output2,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb_q, input2);
input3 = upsample(output2,2); %Upsample by 2
[output3,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgb_q, input3);

figure
plotprecedence(sfgb);

figure
stem(registers3(11,50:100));

% Adder inputs
figure
hold on;
stem(nodes3(10,50:100));
stem(nodes3(22,50:100));
hold off;



%% TASK 2
close all
sfgb2 = [];

sfgb2 = addoperand(sfgb2, 'in', 1, 1);
sfgb2 = addoperand(sfgb2, 'twoport', 1, [1 3], [4 2], a3, 'symmetric');
sfgb2 = addoperand(sfgb2, 'twoport', 2, [4 6], [7 5], a7, 'symmetric');
sfgb2 = addoperand(sfgb2, 'twoport', 3, [1 9], [10 8], a1, 'symmetric');
sfgb2 = addoperand(sfgb2, 'twoport', 4, [10 12], [13 11], a5, 'symmetric');
sfgb2 = addoperand(sfgb2, 'twoport', 5, [13 15], [16 14], a9, 'symmetric');
sfgb2 = addoperand(sfgb2, 'delay', 1, 2, 3);
sfgb2 = addoperand(sfgb2, 'delay', 2, 5, 6);
sfgb2 = addoperand(sfgb2, 'delay', 3, 8, 9);
sfgb2 = addoperand(sfgb2, 'delay', 4, 11, 12);
sfgb2 = addoperand(sfgb2, 'delay', 5, 14, 15);
sfgb2 = addoperand(sfgb2, 'out', 1, 7);
sfgb2 = addoperand(sfgb2, 'out', 2, 16);

plotprecedence(sfgb2);

[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga_q, impulse);
[output2,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb2, output1);
%input3 = upsample(output2,2); %Upsample by 2
input3 = reshape([output2(2,:);output2(1,:)],1,2*length(output2(2,:)));
[output3,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgb2, input3);
output4=reshape([output3(2,:);output3(1,:)],1,2*length(output3(2,:)));

%figure;
%stem(output2(1,:));
%hold on;
%stem(output2(2,:));
%hold off;

[h4,w4] = freqz(output4);
figure
plot(w32/pi,db(h32),'DisplayName','Quantized');
hold on;
plot(w4/pi,db(h4),'DisplayName','Commutated');
hold off;
legend('show');
ylim([-200 50]);

%% Task 3
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


[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfga_q, impulse);
[output2,outputids2,registers2,registerids2,nodes2,nodeids2] = simulate(sfgb2, output1);
%input3 = reshape([output2(2,:);output2(1,:)],1,2*length(output2(2,:)));
[output3,outputids3,registers3,registerids3,nodes3,nodeids3] = simulate(sfgc, output2,[1;2]);
output4=reshape([getnodevalues(output3,outputids3,1);getnodevalues(output3,outputids3,2);getnodevalues(output3,outputids3,3);getnodevalues(output3,outputids3,4)],1,4*length(output3(2,:)));


[h5,w5] = freqz(output4);
figure
plot(w4/pi,db(h4),'DisplayName','Commutated');
hold on;
plot(w5/pi,db(h5),'DisplayName','Unfolded');
hold off;
legend('show');
ylim([-200 50]);

plotprecedence(sfga_q);
plotprecedence(sfgb2);
plotprecedence(sfgc);

sfg_cas2=cascadesfg(sfgb2,sfgc);
sfg_cas = cascadesfg(sfga_q,sfg_cas2);
plotprecedence(sfg_cas);

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


%% Piplining

sfg_cas = insertoperand(sfg_cas,'delay',100,10);
sfg_cas = insertoperand(sfg_cas,'delay',101,22);
sfg_cas = insertoperand(sfg_cas,'delay',102,35);
sfg_cas = insertoperand(sfg_cas,'delay',103,29);
sfg_cas = insertoperand(sfg_cas,'delay',104,40);
sfg_cas = insertoperand(sfg_cas,'delay',105,49);
sfg_cas = insertoperand(sfg_cas,'delay',106,54); 
sfg_cas = insertoperand(sfg_cas,'delay',107,60); 
 
% sfg_cas = insertoperand(sfg_cas,'delay',108,43); 
% sfg_cas = insertoperand(sfg_cas,'delay',109,44); 
% sfg_cas = insertoperand(sfg_cas,'delay',110,53);
% sfg_cas = insertoperand(sfg_cas,'delay',111,54);
% sfg_cas = insertoperand(sfg_cas,'delay',112,60); 

[output1,outputids1,registers1,registerids1,nodes1,nodeids1] = simulate(sfg_cas, impulse);
output5=reshape([getnodevalues(output1,outputids1,1);getnodevalues(output1,outputids1,2);getnodevalues(output1,outputids1,3);getnodevalues(output1,outputids1,4)],1,4*length(output1(2,:)));

% figure;
% stem(output4);
% hold on;
% stem(output5);

[h7,w7] = freqz(output5);
figure
plot(w5/pi,db(h5),'DisplayName','Commutated');
hold on;
plot(w7/pi,db(h7),'DisplayName','Pipelined');
hold off;
legend('show');
ylim([-200 50]);

%  figure
%  plot(w5/pi,angle(h5),'DisplayName','Commutated');
%  hold on;
%  plot(w7/pi,angle(h7),'DisplayName','Pipelined');
%  hold off;
%  legend('show');
%ylim([-200 50]);

%%
figure
freqz(output5);
hold on;
figure
freqz(output4);



%plotprecedence(sfg_cas);