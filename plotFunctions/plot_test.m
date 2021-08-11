 % Plots and figures

close all
time = ubxreciever.TOW-ubxreciever.TOW(1,1);
figure(201)
subplot(2,2,1);  
plot(time(60:end),(deviation(60:end,:))')
xticks(30:60:time(end))
legend('ECEFx', 'ECEFy', 'ECEFz')
title('Deviation of reciever position to true position')


subplot(2,2,2);
plot(time(60:end),ubxreciever.agc(60:end),'b','linewidth',3)
xticks(30:60:time(end))
legend('AGC')
title('AGC over time')

subplot(2,2,3);
plot(time(60:end),ubxreciever.C_over_N0_1(60:end,:))
xticks(30:60:time(end))
legend('C over N0 1')
title('C over N0 1 over time')


subplot(2,2,4);
plot(time(60:end),ubxreciever.Residual(60:end,:))
xticks(30:60:time(end))
legend('Residuals')
title('Residuals over time')