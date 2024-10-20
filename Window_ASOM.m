% Window Mechanism Simulation

% Constants (assumed values, as they weren't provided)
V1 = 1; % ft/s (velocity of drive nut)
V2 = 0.47; % ft/s (velocity of shoe)
R2 = 3; % ft (length of window, estimated from image)

% Create angle array (0 to 90 degrees)
theta2_deg = 0:1:90;
theta2_rad = deg2rad(theta2_deg);

% Calculate omega2 (angular velocity of window)
omega2 = (V1 + V2) ./ (R2 * sin(theta2_rad));

% Calculate angular acceleration of window
alpha2 = omega2.^2 .* tan(theta2_rad);

% Create figure with two subplots
figure('Position', [100, 100, 800, 600]);

% Angular Velocity Plot
subplot(2,1,1);
plot(theta2_deg, omega2, 'b-', 'LineWidth', 2);
title('Angular Velocity of Window');
xlabel('\theta_2 (degrees)');
ylabel('\omega_2 (rad/s)');
grid on;
xlim([0 90]);

% Angular Acceleration Plot
subplot(2,1,2);
plot(theta2_deg, alpha2, 'r-', 'LineWidth', 2);
title('Angular Acceleration of Window');
xlabel('\theta_2 (degrees)');
ylabel('\alpha_2 (rad/s^2)');
grid on;
xlim([0 90]);

% Add overall title to the figure
sgtitle('Window Mechanism Simulation', 'FontSize', 16, 'FontWeight', 'bold');

% Adjust layout
set(gcf, 'Color', 'w');