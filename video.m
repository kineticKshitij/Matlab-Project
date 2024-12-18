%% Setting up the web-camera
clear all; close all; clc; imaqreset;

% Select a valid camera
cam = webcam('Iriun Webcam'); % Use 'Iriun Webcam' or your desired camera name
hShow = imshow(zeros(600, 1000, 3, 'uint8')); title('Camera');

%% Choose color dynamically
colorName = 'Red'; % Default color (can change to 'Blue')
% Detect the color of the selected cloth using color detection and segmentation algorithm
frames = 2000;

for i = 1:frames
    vid_img = snapshot(cam);
    vid_img = flip(vid_img, 2); % Mirror the image horizontally
    
    % Detect the color based on the selected colorName
    object_detected = detect_color(vid_img, colorName);
    
    % Update the displayed image with the detected color areas
    set(hShow, 'CData', object_detected);
    drawnow;
end

% Stop the webcam
stop(cam);
delete(cam);

%% Cleanup
clear all; close all; clc; imaqreset;

%% Detect Color Function (from previous code)
function [highlighted_img] = detect_color(img, colorName)
    % Convert image to HSV color space
    hI = rgb2hsv(img);
    
    % Extract the Hue, Saturation, and Value components
    hImage1 = hI(:,:,1);
    sImage1 = hI(:,:,2);
    vImage1 = hI(:,:,3);

    % Set default HSV thresholds for the chosen color
    switch colorName
        case 'Red'
            hueTL = 0.029; hueTH = 0.98; % Hue range for red
            saturationTL = 0.39; saturationTH = 1;
            valueTL = 0.01; valueTH = 1;
        case 'Blue'
            hueTL = 0.55; hueTH = 0.75; % Hue range for blue
            saturationTL = 0.5; saturationTH = 1;
            valueTL = 0.2; valueTH = 1;
        otherwise
            error('Unsupported color name');
    end

    % Create masks for the chosen color
    hueMask = (hImage1 <= hueTL) | (hImage1 >= hueTH);
    saturationMask = (sImage1 >= saturationTL) & (sImage1 <= saturationTH);
    valueMask = (vImage1 >= valueTL) & (vImage1 <= valueTH);

    % Combine the masks
    colorObjectsMask = hueMask & saturationMask & valueMask;

    % Process the mask to remove noise and fill holes
    out2 = imfill(colorObjectsMask, 'holes');
    out3 = bwmorph(out2, 'erode', 2);
    out3 = bwmorph(out3, 'dilate', 3);
    out3 = imfill(out3, 'holes');

    % Overlay the detected region on the original image
    highlighted_img = imoverlay(img, out3);
end
