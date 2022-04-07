% Signal flow graph
sfg = [];
sfg = addoperand(sfg, 'in', 1, 1);
sfg = addoperand(sfg, 'add', 1, [1 2], 3);
sfg = addoperand(sfg, 'delay', 1, 3, 4);
sfg = addoperand(sfg, 'constmult', 1, 4, 2, 0.5);
sfg = addoperand(sfg, 'out', 1, 4);

dotsfgplot(sfg, 'eps')

%% 1 a)
resp = impulseresponse(sfg, 128);
resp_m = resp(resp>0.1)

%% 1 b)
freqz(resp)
% --> lowpass filter

%% 3 a)
clc
a0 = 57/256;
a2 = a0;
a1 = 55/128;
b1 = 179/512;
b2 = -171/512;

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

N = 64;
%% 3 b)
printprecedence(sfg)

%% 3 c)
resp = impulseresponse(sfg, N);
%plot(resp)

random = 2*rand(1, 1024)-1;
impulse = [1, zeros(1,N-1)];
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg, impulse);


%% 3 d)
freqz(resp)
%[h,w] = freqz(resp);
%plot(w/pi, db(h));
%hold on
%plot([0,1], [-1.023 -1.023])

%% 3 e)


%% 3 f)

% a node is interesting if it can overflow
% 2, 3, 10, 12
plot(nodes')
grid on

%% 3 g)
% safe scaling criterion: L1 norm of the node values if the global input
% has an impulse at the input

node_sum = sum(abs(nodes'));
display(node_sum(2))
display(node_sum(3))
display(node_sum(10))
display(node_sum(12))


%% 3 h)
% first addtion (node 2) overflows
% scale x(n) input by 0.5
% correct output y(n) by 2
sfg_s = sfg;
sfg_s = insertoperand(sfg_s, 'constmult', 6, 1, 0.5);
sfg_s = insertoperand(sfg_s, 'constmult', 7, 12, 2.0);

%errors = checknodes(sfg_s)
dotsfgplot(sfg_s, 'eps')

%% 3 i)
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg_s, impulse);
node_sum = sum(abs(nodes'))

%% 3 j)
resp2 = impulseresponse(sfg_s, N);
plot(resp)
hold on
plot(resp2)

%% 3 k)
clc
[output_org, outputids, registers, regids, nodes, nodeids] = simulate(sfg_s, impulse);

y1 = simulate(sfg,   impulse, 1, [], [], [1,15]);
y2 = simulate(sfg_s, impulse, 1, [], [], [1,15]);

stem(y1)
hold on
stem(y2)

%% 4 a)
clear; clc;

sfg = [];
sfg = addoperand(sfg, 'in', 1, 1);
sfg = addoperand(sfg, 'twoport', 1, [1, 4], [2, 3], a0, 'symmetric');
sfg = addoperand(sfg, 'delay', 1, 3, 4);
sfg = addoperand(sfg, 'twoport', 2, [ 1,17], [11,13], a1, 'symmetric');
sfg = addoperand(sfg, 'twoport', 3, [13,15], [14,16], a2, 'symmetric');
sfg = addoperand(sfg, 'delay', 2, 14, 15);
sfg = addoperand(sfg, 'delay', 3, 16, 17);
sfg = addoperand(sfg, 'out', 5, 12);






