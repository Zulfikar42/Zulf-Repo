% Piston Mechanism Simulation with Three Loops

% Constants
R2 = 3; % Crank length (inches)
R3 = 8; % Connecting rod length (inches)
omega2_rpm = 200; % Angular velocity of crank (rpm)
omega2 = omega2_rpm * 2*pi/60; % Angular velocity of crank (rad/s)
piston_width = 1.5; % Width of the piston
piston_height = 1; % Height of the piston
num_rotations = 3; % Number of full rotations

% Time vector
t_total = 2*pi/omega2; % Time for one full rotation
t = 0:0.01:t_total * num_rotations;

% Initialize arrays
theta2_deg = mod((omega2 * t + 45) * 180/pi, 360); % Crank angle in degrees, starting at 45 degrees
theta3 = zeros(size(t));
omega3 = zeros(size(t));
alpha3 = zeros(size(t));

% Main calculation loop
for i = 1:length(t)
    theta2_rad = theta2_deg(i) * pi/180; % Convert to radians for calculations
    
    % Calculate theta3
    theta3(i) = asin((-R2 * sin(theta2_rad)) / R3);
    
    % Calculate omega3
    omega3(i) = (-R2 * omega2 * cos(theta2_rad)) / (R3 * cos(theta3(i)));
    
    % Calculate alpha3
    alpha3(i) = (R2 * omega2^2 * sin(theta2_rad) + R3 * omega3(i)^2 * sin(theta3(i))) / (R3 * cos(theta3(i)));
end

% Create a single figure with 3 subplots
figure('Position', [100, 100, 800, 600]);

% Animation subplot
animationPlot = subplot(3,1,1);

% Angular Velocity Plot
velocityPlot = subplot(3,1,2);
plot(velocityPlot, t, omega3);
title(velocityPlot, 'Angular Velocity of Connecting Rod');
xlabel(velocityPlot, 'Time (s)');
ylabel(velocityPlot, 'Angular Velocity (rad/s)');

% Angular Acceleration Plot
accelerationPlot = subplot(3,1,3);
plot(accelerationPlot, t, alpha3);
title(accelerationPlot, 'Angular Acceleration of Connecting Rod');
xlabel(accelerationPlot, 'Time (s)');
ylabel(accelerationPlot, 'Angular Acceleration (rad/s^2)');

% Animation loop
for i = 1:length(t)
    theta2_rad = theta2_deg(i) * pi/180; % Convert to radians for position calculations
    
    % Calculate positions
    x_crank = R2 * cos(theta2_rad);
    y_crank = R2 * sin(theta2_rad);
    x_piston = R2 * cos(theta2_rad) + R3 * cos(theta3(i));
    
    % Update animation subplot
    subplot(animationPlot);
    cla(animationPlot);
    
    % Plot mechanism
    plot([0 x_crank], [0 y_crank], 'b-', 'LineWidth', 2); % Crank
    hold on;
    plot([x_crank x_piston], [y_crank 0], 'r-', 'LineWidth', 2); % Connecting rod
    
    % Draw rectangular piston
    rectangle('Position', [x_piston - piston_width/2, -piston_height/2, piston_width, piston_height], ...
              'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'k');
    
    % Center-align the animation
    xlim([-R2-R3, R2+R3]);
    ylim([-R2-1, R2+1]);
    axis equal;
    title(sprintf('Piston Mechanism Animation\nTime: %.2f s, Crank Angle: %.1f°', t(i), theta2_deg(i)));
    xlabel('X position');
    ylabel('Y position');
    
    % Draw a line to represent the cylinder
    line([-R2-R3, R2+R3], [0, 0], 'Color', 'k', 'LineStyle', '--');
    
    hold off;
    
    % Update velocity plot
    subplot(velocityPlot);
    plot(velocityPlot, t(1:i), omega3(1:i), 'b-');
    title(velocityPlot, 'Angular Velocity of Connecting Rod');
    xlabel(velocityPlot, 'Time (s)');
    ylabel(velocityPlot, 'Angular Velocity (rad/s)');
    xlim([0, t_total * num_rotations]);
    
    % Update acceleration plot
    subplot(accelerationPlot);
    plot(accelerationPlot, t(1:i), alpha3(1:i), 'r-');
    title(accelerationPlot, 'Angular Acceleration of Connecting Rod');
    xlabel(accelerationPlot, 'Time (s)');
    ylabel(accelerationPlot, 'Angular Acceleration (rad/s^2)');
    xlim([0, t_total * num_rotations]);
    
    drawnow;
end