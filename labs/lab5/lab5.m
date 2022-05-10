
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






