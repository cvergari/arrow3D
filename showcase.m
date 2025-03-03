
close all 
clear all
clc


% Random points
x = randn(10,1)*10;
y = randn(10,1)*10;
z = randn(10,1)*10;

arrowhead_size = abs(rand(10,1) * 5 + 1);
arrowhead_length = abs(rand(10,1) * 5 + 1);

% Create arrows
c = lines(10);
for k = 1 : length(x) - 1
    h(k) = arrow3D(x(k:k+1),y(k:k+1),z(k:k+1));
    h(k).Color = c(k,:);  % change arrow color
    h(k).ArrowHeadRadius = arrowhead_size(k);
    h(k).ArrowHeadLength = arrowhead_length(k);

end

lighting gouraud;
light;
axis equal;