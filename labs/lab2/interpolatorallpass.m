
% addpath /courses/TSTE87/matlab/
addpath ../../../newasictoolbox/

%%


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

