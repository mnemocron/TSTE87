sfg=addoperand([],'in',1,1);
sfg=addoperand(sfg,'constmult',1,1,2,0.25);
sfg=addoperand(sfg,'constmult',2,4,5,0.75);
sfg=addoperand(sfg,'add',1,[2 1],6);
sfg=addoperand(sfg,'add',2,[2 5],3);
sfg=addoperand(sfg,'add',3,[6 4],7);
sfg=addoperand(sfg,'delay',1,3,4);
sfg=addoperand(sfg,'out',1,7);
