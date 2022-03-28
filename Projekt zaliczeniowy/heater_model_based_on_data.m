% @author  Dominik Luczak
% @date    2021-11-19
clear all, close all, clc

temperature = load('data_pid_controller_20211220-035636.txt');
dt=1; %one second
number_of_samples = length(temperature);
t = (0:number_of_samples-1)*dt;

%Input signal
input_amplitude = 0.5; % 0.9 -> 90% of PWM duty (PWM1=90;)
input = input_amplitude*ones( 1 ,number_of_samples); 

%LTI model (linear time-invariant model)
s = tf('s');
k = 16.95/input_amplitude;   %model gain
T = 1948-1590-83;%72 323   %model time constant
delay=25;   %model delay
H = k/(1+s*T)*exp(-s*delay); % model
disp(sprintf('Model parameters k=%.2g, T=%g, delay=%g\n', k, T, delay));

%Model response
model_response = lsim(H,input,t);
model_response = model_response + 23.5; %add offset

%Model error
residuum = temperature - model_response';
error_abs_sum = sum(abs(residuum));
disp(sprintf('Model error sum(abs(residuum)) = %g\n', error_abs_sum));

figure(1);
plot(t,temperature, '.', t, model_response, '.');
title('(author: D. Luczak)');
xlabel('Time (s)');
ylabel('Temperature (C)');

%k=34, T=275, delay=25
legend('measurement samples', 'model reponse of heater+BMP280');
axis tight;

figure(2);
plot(t,residuum, '.');
title('Residuum (measurement samples - model reponse)');
xlabel('Time (s)');
ylabel('Temperature (C)');
axis tight;
ylim([-0.5 0.5]);


[Gsnum, Gsden]=tfdata(H);
%Conversion to discrete model
H_discrete = c2d(H, dt, 'tustin');
disp(H_discrete)
%Second order sections
[sos, g] = tf2sos(cell2mat(H_discrete.num), cell2mat(H_discrete.den));
disp('gain:');
disp(g);
disp('sos matrix:');
disp(sos);



