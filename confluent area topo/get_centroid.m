function [x_cen,y_cen]=get_controid(x, y)
%code copied from POLYGEOM by H.J. Sommer
%http://www.mathworks.com/matlabcentral/fileexchange/319-polygeom-m

% check if inputs are same size
if ~isequal( size(x), size(y) ),
  error( 'X and Y must be the same size');
end
 
% temporarily shift data to mean of vertices for improved accuracy
xm = mean(x);
ym = mean(y);
x = x - xm;
y = y - ym;
  
% summations for CCW boundary
xp = x( [2:end 1] );
yp = y( [2:end 1] );
a = x.*yp - xp.*y;
 
A = sum( a ) /2;
xc = sum( (x+xp).*a  ) /6/A;
yc = sum( (y+yp).*a  ) /6/A;

% replace mean of vertices
x_cen = xc + xm;
y_cen = yc + ym;