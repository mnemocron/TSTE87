

clear all; close all; clc
% addpath /courses/TSTE87/matlab/
addpath ../../../newasictoolbox/

%% 

sfg=addoperand([],'in',1,1);
sfg=addoperand(sfg,'constmult',1,1,2,0.25);
sfg=addoperand(sfg,'constmult',2,4,5,0.75);
sfg=addoperand(sfg,'add',1,[2 1],6);
sfg=addoperand(sfg,'add',2,[2 5],3);
sfg=addoperand(sfg,'add',3,[6 4],7);
sfg=addoperand(sfg,'delay',1,3,4);
sfg=addoperand(sfg,'out',1,7);

plotprecedence(sfg)

%% a) 
% Compute an initial schedule and print it. 
% Assume latency = execution time = 2 time units.

timinginfo = getdefaulttiminginfo;
timinginfo.constmult.latency = 2;
timinginfo.constmult.executiontime = 2;
timinginfo.add.latency = 2;
timinginfo.add.executiontime = 2;

schedule = getinitialschedule(sfg, timinginfo);

plotschedule(schedule)

%% b) Print the possible changes in start times.
printstarttimes(schedule)

%% c) 
% Reschedule so that at most one multiplication and one addition are 
% executed in parallel, with a schedule time of at most six time units. 
% Note that it is possible to move outputs.
clc
re_schedule = schedule;
re_schedule = changestarttime(re_schedule, 'add', 2, 2);
re_schedule = changestarttime(re_schedule, 'constmult', 2, 2);
re_schedule = changestarttime(re_schedule, 'add', 2, 2);
plotschedule(re_schedule)
printstarttimes(re_schedule)



