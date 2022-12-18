function setuprop(handle, name, value)
%SETUPROP Set a user-defined property in a figure or axes object.
%	SETUPROP(H, NAME, VALUE) sets a user-defined property in
%	the figure or axes object with handle H.  The
%	user-defined property, which is created if it does not
%	already exist, is assigned a NAME and a VALUE.  VALUE may
%	be any matrix except a sparse matrix.
%
%	See also: getuprop, clruprop.


%	Steven L. Eddins, October 1994
%	Copyright (c) 1995 by The MathWorks, Inc.
%	$Revision: 1.6 $  $Date: 1995/01/29 05:21:36 $

tryString = 'objType = get(handle, ''type'');';
catchString = 'failed = 1;';
failed = 0;

eval(tryString, catchString);
if (failed)
  error('H is not a valid handle.');
end

oType = objType(1);
if (oType == 'f')
  container = findobj(handle, ...
      'Type', 'uicontrol', ...
      'Style', 'text', ...
      'Tag', name);
  if (isempty(container))
    container = uicontrol(handle, ...
	'Style', 'text', ...
	'Tag', name, ...
	'UserData', value, ...
	'Visible', 'off');
  else
    set(container, 'UserData', value);
  end
  
elseif (oType == 'a')
  container = findobj(handle, ...
      'Type', 'text', ...
      'Tag', name);
  if (isempty(container))
    currentAxes = gca;
    container = text( ...
	'Tag', name, ...
	'Visible', 'off');
    if (handle ~= currentAxes)
      h = copyobj(container);
      delete(container);
      container = h;
      set(container, 'Parent', handle);
    end
    set(container, 'UserData', value);
  else
    set(container, 'UserData', value);
  end
  
else
  
  error(sprintf('Cannot create a user property for "%s" objects.', objType));
    
end