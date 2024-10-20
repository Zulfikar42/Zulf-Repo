% Parameters
lift = 30; % mm
base_radius = 25; % mm
roller_radius = 15; % mm
total_angle = 360; % degrees
rise_angle = 90; % degrees
dwell_angle = 50; % degrees
return_angle = 90; % degrees

% Generate angle array
theta = linspace(0, total_angle, 1000);

% Initialize displacement array
s = zeros(size(theta));

% Cycloidal motion during opening (0 to 90 degrees)
rise_idx = theta <= rise_angle;
s(rise_idx) = lift * (theta(rise_idx)/rise_angle - sin(2*pi*theta(rise_idx)/rise_angle)/(2*pi));

% Dwell at full open position (90 to 140 degrees)
dwell_idx = (theta > rise_angle) & (theta <= (rise_angle + dwell_angle));
s(dwell_idx) = lift;

% SHM during closing (140 to 230 degrees)
return_idx = (theta > (rise_angle + dwell_angle)) & (theta <= (rise_angle + dwell_angle + return_angle));
return_theta = theta(return_idx) - (rise_angle + dwell_angle);
s(return_idx) = lift * (1 + cos(pi * return_theta / return_angle)) / 2;

% Generate cam profile
cam_x = (base_radius + s) .* cos(theta*pi/180) + roller_radius * sin(theta*pi/180);
cam_y = (base_radius + s) .* sin(theta*pi/180) - roller_radius * cos(theta*pi/180);

% Calculate velocity and acceleration
dtheta = diff(theta) * pi / 180; % Convert to radians
v = diff(s) ./ dtheta;
a = diff(v) ./ dtheta(1:end-1);

% Create figure with larger size
fig = figure('Position', [100, 100, 1200, 1000]);

% Create subplots with modified layout
animation_ax = subplot(4, 2, 1); % Top left
profile_ax = subplot(4, 2, 2);   % Top right
displacement_ax = subplot(4, 2, [3,4]); % Third row full width
velocity_ax = subplot(4, 2, [5,6]); % Fourth row full width
acceleration_ax = subplot(4, 2, [7,8]); % Fifth row full width

% Initialize animated lines
disp_line = animatedline(displacement_ax, 'Color', 'b', 'LineWidth', 2);
vel_line = animatedline(velocity_ax, 'Color', 'g', 'LineWidth', 2);
acc_line = animatedline(acceleration_ax, 'Color', 'm', 'LineWidth', 2);

% Set axis limit for animation and profile
axis_limit = max(max(abs(cam_x)), max(abs(cam_y))) + roller_radius + lift + 10;

% Configure displacement plot
xlabel(displacement_ax, 'Cam Angle (degrees)');
ylabel(displacement_ax, 'Displacement (mm)');
title(displacement_ax, 'Follower Displacement');
grid(displacement_ax, 'on');
xlim(displacement_ax, [0, total_angle * 4]);
ylim(displacement_ax, [0, lift*1.1]);

% Configure velocity plot
xlabel(velocity_ax, 'Cam Angle (degrees)');
ylabel(velocity_ax, 'Velocity (mm/rad)');
title(velocity_ax, 'Follower Velocity');
grid(velocity_ax, 'on');
xlim(velocity_ax, [0, total_angle * 4]);
ylim(velocity_ax, [min(v)*1.1, max(v)*1.1]);

% Configure acceleration plot
xlabel(acceleration_ax, 'Cam Angle (degrees)');
ylabel(acceleration_ax, 'Acceleration (mm/rad^2)');
title(acceleration_ax, 'Follower Acceleration');
grid(acceleration_ax, 'on');
xlim(acceleration_ax, [0, total_angle * 4]);
ylim(acceleration_ax, [min(a)*1.1, max(a)*1.1]);

% Configure profile plot
plot(profile_ax, cam_x, cam_y, 'r', 'LineWidth', 2);
axis(profile_ax, 'equal');
xlabel(profile_ax, 'X (mm)');
ylabel(profile_ax, 'Y (mm)');
title(profile_ax, 'Cam Profile');
grid(profile_ax, 'on');
hold(profile_ax, 'on');

% Plot base circle on profile
base_circle_x = base_radius * cos(linspace(0, 2*pi, 100));
base_circle_y = base_radius * sin(linspace(0, 2*pi, 100));
plot(profile_ax, base_circle_x, base_circle_y, 'b--', 'LineWidth', 1.5);

% Set equal aspect ratio and limits for profile plot
axis(profile_ax, 'equal');
xlim(profile_ax, [-axis_limit, axis_limit]);
ylim(profile_ax, [-axis_limit, axis_limit]);

% Animation parameters
num_frames = 400;
rotation_angles = linspace(0, 8*pi, num_frames); % 4 complete rotations

% Animation loop
for frame = 1:num_frames
    cla(animation_ax);
    
    % Calculate rotated cam profile
    rot_angle = rotation_angles(frame);
    rot_matrix = [cos(rot_angle) -sin(rot_angle); sin(rot_angle) cos(rot_angle)];
    rotated_points = rot_matrix * [cam_x; cam_y];
    
    % Plot rotating cam
    plot(animation_ax, rotated_points(1,:), rotated_points(2,:), 'b', 'LineWidth', 2);
    hold(animation_ax, 'on');
    
    % Calculate current angle and follower position
    current_angle = mod(rot_angle * 180/pi, 360);
    total_angle_deg = rot_angle * 180/pi;
    follower_pos = interp1(theta, s, current_angle);
    
    % Plot follower
    follower_x = [0, 0];
    follower_y = [max(rotated_points(2,:)) + roller_radius, max(rotated_points(2,:)) + roller_radius + follower_pos];
    plot(animation_ax, follower_x, follower_y, 'k', 'LineWidth', 2);
    
    % Plot roller
    roller_center_x = 0;
    roller_center_y = max(rotated_points(2,:)) + roller_radius;
    viscircles(animation_ax, [roller_center_x, roller_center_y], roller_radius, 'Color', 'g');
    
    % Plot base circle
    viscircles(animation_ax, [0, 0], base_radius, 'Color', 'r', 'LineStyle', '--');
    
    % Set animation axis properties
    axis(animation_ax, 'equal');
    xlim(animation_ax, [-axis_limit, axis_limit]);
    ylim(animation_ax, [-axis_limit, axis_limit]);
    xlabel(animation_ax, 'X (mm)');
    ylabel(animation_ax, 'Y (mm)');
    title(animation_ax, ['Cam and Follower Animation: ', num2str(current_angle, '%.1f'), ' degrees']);
    grid(animation_ax, 'on');
    
    % Update plots with continuous angle
    addpoints(disp_line, total_angle_deg, follower_pos);
    
    % Update velocity plot
    current_vel = interp1(theta(1:end-1), v, current_angle);
    addpoints(vel_line, total_angle_deg, current_vel);
    
    % Update acceleration plot
    current_acc = interp1(theta(1:end-2), a, current_angle);
    addpoints(acc_line, total_angle_deg, current_acc);
    
    drawnow;
    pause(0.01);
end

% Calculate and display maximum velocity and acceleration
fprintf('Maximum velocity during rise: %.2f mm/rad\n', max(abs(v(rise_idx(1:end-1)))));
fprintf('Maximum velocity during return: %.2f mm/rad\n', max(abs(v(return_idx(1:end-1)))));
fprintf('Maximum acceleration during rise: %.2f mm/rad^2\n', max(abs(a(rise_idx(1:end-2)))));
fprintf('Maximum acceleration during return: %.2f mm/rad^2\n', max(abs(a(return_idx(1:end-2)))));