
addpath /courses/TSTE87/matlab/
% addpath ../../../newasictoolbox/

%%
clear all; clc
schedule = [
48	2	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
1	1	1	NaN	NaN	NaN	NaN	NaN	0	NaN	2	0	0
11	1	1	11	2	11	0.457300000000000	3	0	0	2	15	8
11	3	32	21	32	22	-0.569500000000000	3	0	0	4	15	8
11	5	52	41	52	42	-0.0952000000000000	3	0	1	22	15	8
11	7	72	61	72	62	0.449000000000000	3	0	0	0	15	8
11	8	5	65	15	65	-0.242429000000000	3	0	0	44	15	8
11	10	5	56	17	56	-0.0681290000000000	3	0	0	40	15	8
11	13	64	40	25	23	-0.0681290000000000	3	0	0	46	15	8
11	15	28	45	49	29	-0.888980000000000	3	0	0	38	15	8
11	16	64	47	36	34	-0.242429000000000	3	0	0	42	15	8
2	2	50	NaN	NaN	NaN	NaN	NaN	0	NaN	27	0	0
2	4	55	NaN	NaN	NaN	NaN	NaN	0	NaN	47	0	0
11	2	2	22	3	21	-0.209800000000000	3	0	0	20	15	8
11	4	3	42	4	41	-0.212300000000000	3	0	0	6	15	8
11	9	15	67	16	67	-0.678715000000000	3	0	0	36	15	8
11	11	17	58	18	58	-0.461024000000000	3	0	0	8	15	8
11	14	25	44	28	26	-0.461024000000000	3	0	0	18	15	8
11	17	36	48	50	37	-0.678715000000000	3	0	0	12	15	8
11	18	16	23	39	40	-0.0681290000000000	3	0	0	16	15	8
11	20	43	29	54	45	-0.888980000000000	3	0	0	14	15	8
11	21	16	34	46	47	-0.242429000000000	3	0	0	10	15	8
2	1	49	NaN	NaN	NaN	NaN	NaN	0	NaN	5	0	0
11	6	4	62	5	61	-0.225800000000000	3	0	0	24	15	8
11	12	18	60	64	60	-0.888980000000000	3	0	0	26	15	8
11	19	39	26	43	44	-0.461024000000000	3	0	0	34	15	8
11	22	46	37	55	48	-0.678715000000000	3	0	0	32	15	8
2	3	54	NaN	NaN	NaN	NaN	NaN	0	NaN	29	0	0];


%%

scheduletime = schedule(1,1);
generatetimingcontroller(scheduletime);

%%
mv = extractmemoryvariables(schedule);
[mvlist, iv] = memorypartitioning(mv, 1, 1, 1); % 1R 1W 1parallel
peassignment = getpeassignment(schedule);
disp(length(mvlist))  % 2 memories

cellassignment_1 = leftedgealgorithm(mvlist{1});
cellassignment_2 = leftedgealgorithm(mvlist{2});


%%
BIT_RESOLUTION = 10;

generatememorycontroller(cellassignment_1, 1);
generatememorycontroller(cellassignment_2, 2);

generatepecontroller(peassignment{1}, schedule, 1, BIT_RESOLUTION);
generatepecontroller(peassignment{2}, schedule, 2, BIT_RESOLUTION);
generatepecontroller(peassignment{3}, schedule, 3, BIT_RESOLUTION);
generatepecontroller(peassignment{4}, schedule, 4, BIT_RESOLUTION);


%%
clc

plotcellassignment(cellassignment_1)
plotcellassignment(cellassignment_2)

%% Task 2
clear all;clc;

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

timinginfo = getdefaulttiminginfo;
timinginfo.twoport.latency = 3;
timinginfo.twoport.executiontime = 3;

schedule = getinitialschedule(sfga, timinginfo);

plotschedule(schedule)
printstarttimes(schedule)

%% c)
sfg_f = flattensfg(sfga);
schedule = getinitialschedule(sfg_f, timinginfo);

plotschedule(schedule)

% 4 sub
% 4 constmult
% 8 add

%% d)
addpath /courses/TSTE87/labs/evaluation/

%% e)
schedule_e = evaluation(sfg_f, [Inf, Inf, Inf], 1,0);

plotschedule(schedule_e)
% identical to before because resources are not limited

%% f)
schedule_c = evaluation(sfg_f, [1, 2, 1], 1,0);

plotschedule(schedule_c)
% takes 13 instead of 12 time units


%% g)
% There are 11 registers.
% There are 15 multiplexers:
mux_input_count = 2*8 + 3*2 + 4*2 + 5*1 + 6*1 + 7*1

%% h)
sfg_p = sfga;
sfg_p = insertoperand(sfg_p, 'delay', 8, 10);
sfg_p = insertoperand(sfg_p, 'delay', 9, 16);
sfg_p = flattensfg(sfg_p);

schedule_p = getinitialschedule(sfg_p, timinginfo);
plotschedule(schedule_p)

%% i)
schedule_p = evaluation(sfg_p, [1, 2, 1], 1,0);

plotschedule(schedule_p)
% takes more time than wih infinite resources
% 9 instead of 6

%% j)
% There are 13 registers.
% There are 16 multiplexers:
mux_input_count = 2*7 + 3*4 + 5*2 + 6*2 + 7*1

%% k)
schedule_tp = evaluation(sfg_p, [2, 4, 2], 1,0);

plotschedule(schedule_tp)
% takes more time than wih infinite resources
% 7 instead of 6

%% l)
% There are 16 registers.
% There are 27 multiplexers:
mux_input_count = 4*4 + 3*5 + 2*18


%% m)

plotschedule(getinitialschedule(sfg_p, timinginfo))
plotschedule(schedule_p)

% Resource utilization

% original
% add: 2/6
% sub: 2/6
% constmult: 2/6

% pipelined 1x twoports
% add: 7/9
% sub: 7/9
% constmult: 7/9

% pipelined 2x twoports
% add: 3.5/7
% sub: 3.5/7
% constmult: 3.5/7

