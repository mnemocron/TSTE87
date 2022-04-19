% https://pastebin.com/yenkgFim

%%
% Test interpolator filter
%
sinusoid = sin(0:pi/8:6*pi);
sin_interpolated = simulate_interpolator_task1(sfga, sfgb, sinusoid);
sin_upsampled = upsample(sinusoid, 4);
figure; stem(sin_upsampled); hold on; stem(sin_interpolated);
xlabel('Sample'); ylabel('Amplitude'); legend('Input', 'Output');
ylim([-1.1 1.1]);

