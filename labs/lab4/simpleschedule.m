
addpath /courses/TSTE87/matlab/
% addpath ../../../newasictoolbox/

%% 1
% This is a simple filter, where adders have a latency and execution time 
% of one time unit and multipliers have a latency and executiontime of 
% two time units.
clear; close all; clc;
schedule = [
    [4 2 NaN NaN NaN NaN NaN NaN NaN NaN];
    [1 1 1 NaN NaN 0 NaN 0 0 0];
    [2 1 8 NaN NaN 0 NaN 3 0 0];
    [5 1 1 2   0.5 0 NaN 0 2 2];
    [5 2 2 3   0.5 0 NaN 2 2 2];
    [5 3 4 5   0.5 0 NaN 1 2 2];
    [5 4 6 7   0.5 0 NaN 3 2 2];
    [3 1 2 3   4   0 0   0 1 1];
    [3 2 4 5   6   0 0   3 1 1];
    [3 3 7 5   8   0 0   2 1 1]];
 
%% a)
% Extract and print/plot the memory variables
mv = extractmemoryvariables(schedule);
plotmemoryvariables(mv)

%% b)
% Partition the memory variables using memories with one read port and one 
% write port, assuming that it is possible to read and write concurrently. 
% How many memories are required? How can the number of memories be reduced?
[mvlist, iv] = memorypartitioning(mv, 1, 1, 2); % 1R 1W 2parallel
disp(length(mvlist))  % 2 memories

% this one determines the NUMBER OF MEMORIES
% which is a direct consequence of the NUMBER OF R/W ACCESSES
% and the type of memory used

%% c)
% Apply the left edge algorithm to each memory. How many memory cells are
% required for each memory?
clc
cellassignment_1 = leftedgealgorithm(mvlist{1});
cellassignment_2 = leftedgealgorithm(mvlist{2});
disp(length(cellassignment_1))  % 3 cells
disp(length(cellassignment_2))  % 2 cells
plotcellassignment(cellassignment_1)
plotcellassignment(cellassignment_2)

% this one determines the NUMBER OF MEMORY CELLS per memory
% (e.g. how many adressable slots are in the memory)
% this is a consequence of the amount of variables that can be stored in 
% parallel on the type of memory without R/W access conflicts
%% d) 
% Determine the number of adders and multipliers required
close all; clc
plotschedule(schedule)
peassignment = getpeassignment(schedule);
printpeassignment(peassignment)
% 1 adders
% 2 multipliers

%% e)
% Assume that pipelining is introduced in the multipliers so that the 
% execution time is halved. Change the execution time of the multipliers 
% to one time unit.
clc
schedule_pipe = updatepetiming(schedule, [2 1], 'constmult');


%% d) 
% Determine the number of adders and multipliers required
clc
peassignment = getpeassignment(schedule_pipe);
printpeassignment(peassignment)
% 1 adder
% 1 multiplier
peassignment = getpeassignment(schedule_pipe);
% printpeassignment(peassignment)
printinterconnection(mvlist{1}, peassignment)
printinterconnection(mvlist{2}, peassignment)

% adder input 2 does not read from 2nd memory

%% e)
% Analyse the interconnect between the memories and processing elements.
% Draw by hand an interconnect schematic for memories and PEs.
clc
plotschedule(schedule_pipe)
mvp = extractmemoryvariables(schedule_pipe);
plotmemoryvariables(mvp)

%% Task 2
% In this task we will use the schedule of the single rate realization of 
% the interpolator filter from Task 2 of Laboratory work 3. 
% Make sure that you save all results!
clear; close all; clc;

schedule = [
[24   2 NaN NaN NaN NaN       NaN NaN NaN NaN NaN NaN NaN];
[ 1   1   1 NaN NaN NaN       NaN NaN   0 NaN   0   0   0];
[11   1   1  11   2	 11  0.457300   3   0   0   1   8   4];
[11   3  21  32  22	 32  0.569500   3   0   0   2   8   4];
[11   5  41  52  42	 52  0.095200   3   0   1  11   8   4];
[11   7  61  72  62	 72 -0.449000   3   0   0   0   8   4];
[11   8   5  65  15	 65 -0.242429   3   0   0  22   8   4];
[11  10   5  56  17	 56 -0.068129   3   0   0  20   8   4];
[11  13  64  40  25	 23 -0.068129   3   0   0  23   8   4];
[11  15  28  45  49	 29 -0.888980   3   0   0  19   8   4];
[11  16  64  47  36	 34 -0.242429   3   0   0  21   8   4];
[ 2   2  50 NaN NaN NaN       NaN NaN   0 NaN   0   0   0];
[ 2   4  55 NaN NaN NaN       NaN NaN   0 NaN   0   0   0];
[11   2   2  22   3  21 -0.209800   3   0   0  10   8   4];
[11   4   3  42   4  41 -0.212300   3   0   0   3   8   4];
[11   9  15  67  16  67 -0.678715   3   0   0  18   8   4];
[11  11  17  58  18  58 -0.461024   3   0   0   4   8   4];
[11  14  25  44  28  26 -0.461024   3   0   0   9   8   4];
[11  17  36  48  50  37 -0.678715   3   0   0   6   8   4];
[11  18  16  23  39  40 -0.068129   3   0   0   8   8   4];
[11  20  43  29  54  45 -0.888980   3   0   0   7   8   4];
[11  21  16  34  46  47 -0.242429   3   0   0   5   8   4];
[ 2   1  49 NaN NaN NaN       NaN NaN   0 NaN   8   0   0];
[11   6   4  62   5  61 -0.225800   3   0   0  12   8   4];
[11  12  18  60  64  60 -0.888980   3   0   0  13   8   4];
[11  19  39  26  43  44 -0.461024   3   0   0  17   8   4];
[11  22  46  37  55  48 -0.678715   3   0   0  16   8   4];
[ 2   3  54 NaN NaN NaN       NaN NaN   0 NaN  16   0   0]];

%% a) 
% To avoid concurrent reads and writes, increase the resolution of the 
% schedule by a factor of two and decrease the latency of each twoport by
% one time unit. This should result in a latency of 15 time units and an 
% execution time of 8 time units.

schedule = updatetimescale(schedule, 2); % factor of 2
schedule = updatepetiming(schedule, [15 8], 'twoport');

%% b) 
% Extract the memory variables and partition the memories using memories 
% with one read and one write port with at most one concurrent memory 
% access. How many memories are required?
mv = extractmemoryvariables(schedule);
plotmemoryvariables(mv)
[mvlist, iv] = memorypartitioning(mv, 1, 1, 1); % 1R 1W 1parallel
disp(length(mvlist))  % 5 memories
%  PE req
%% c) 
% Apply the left edge algorithm and determine the number of cells required.
clc
cellassignment_1 = leftedgealgorithm(mvlist{1});
cellassignment_2 = leftedgealgorithm(mvlist{2});
cellassignment_3 = leftedgealgorithm(mvlist{3});
cellassignment_4 = leftedgealgorithm(mvlist{4});
cellassignment_5 = leftedgealgorithm(mvlist{5});
disp(length(cellassignment_1))  % 8 cells
disp(length(cellassignment_2))  % 9 cells
disp(length(cellassignment_3))  % 4 cells
disp(length(cellassignment_4))  % 1 cells
disp(length(cellassignment_5))  % 1 cells
plotcellassignment(cellassignment_1)
plotcellassignment(cellassignment_2)
plotcellassignment(cellassignment_3)
plotcellassignment(cellassignment_4)
plotcellassignment(cellassignment_5)

% Perform processing element assignment and determine the number of PEs
%% d)
% Analyse the interconnect and try to minimize the number of PE ports 
% connected to each memory. Comments?
% --> get down to 2 memories
% - flip twoports in SFG
% - move outports as early as possible
close all;
peassignment = getpeassignment(schedule);
printinterconnection(mvlist{1}, peassignment)
printinterconnection(mvlist{2}, peassignment)
printinterconnection(mvlist{3}, peassignment)
printinterconnection(mvlist{4}, peassignment)
printinterconnection(mvlist{5}, peassignment)

%%
clc; close
% use CTRL+F to count zeroes in the output of printinterconnection
% --> maximize the number of zeroes
% which means, to reduce interconnects to memories

re_schedule = schedule;
% move outports as early as possible
re_schedule = changestarttime(re_schedule, 'out', 1, -11);
re_schedule = changestarttime(re_schedule, 'out', 2, -21);
re_schedule = changestarttime(re_schedule, 'out', 3, -3);
re_schedule = changestarttime(re_schedule, 'out', 4, -1);
% printstarttimes(re_schedule)

% move input ports as late as possible
re_schedule = changestarttime(re_schedule, 'in', 1, 2);
% flip twoports in SFG so that in and out ports are directly connected
re_schedule = fliptwoport(re_schedule, 3);
re_schedule = fliptwoport(re_schedule, 5);
re_schedule = fliptwoport(re_schedule, 7);

mv = extractmemoryvariables(re_schedule);
[mvlist, iv] = memorypartitioning(mv, 1, 1, 1); % 1R 1W 1parallel
peassignment = getpeassignment(re_schedule);
disp(length(mvlist))  % 2 memories

% in what order are the non connected ports?
printinterconnection(mvlist{1}, peassignment)
printinterconnection(mvlist{2}, peassignment)


