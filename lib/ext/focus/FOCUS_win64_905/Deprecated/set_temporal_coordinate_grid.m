function ps=set_temporal_coordinate_grid(varargin)

error(['"set_temporal_coordinate_grid" is obsolete.  Use "set_time_samples" instead, along with "set_coordinate_grid".  ', ...
'Also, the calling sequence for "fnm_tsd", "fnm_transient", and "rayleigh_transient" has changed.  See the examples and/or the documentation for details.'])

% if nargin()==0
%	disp('Please enter the following variables:')
%	disp('delta, xmin, xmax, ymin, ymax, zmin, zmax, tmin, tmax, deltat')
%	disp('delta can be a 1x1 or a 1x3 array')
%	delta=input('delta');
%	xmin=input('xmin');
%	xmax=input('xmax');
%	ymin=input('ymin');
%	ymax=input('ymax');
%   zmin=input('zmin');
%    zmax=input('zmax');
%	tmin=input('tmin');
%	tmax=input('tmax');
%	deltat=input('deltat');
%	ps=set_temporal_coordinate_grid(delta,xmin,xmax,ymin,ymax,zmin,zmax,tmin,tmax,deltat);
%	return

	
% elseif nargin()==10
%    ps.delta=varargin{1};
%    ps.xmin=varargin{2};
%    ps.xmax=varargin{3};
%    ps.ymin=varargin{4};
%    ps.ymax=varargin{5};
%    ps.zmin=varargin{6};
%    ps.zmax=varargin{7};
%    ps.tmin=varargin{8};
%    ps.tmax=varargin{9};
%	ps.deltat=varargin{10};
%    ps.vector_flag=-1;
%	ps.time_flag=-1;
%    ps.vector=[];
%    ps.polar=-1;
%    ps.spherical=-1;
%    if ps.delta(1)<0
%        error('delta cannot be <0')
%    end
%    if length(ps.delta)==1
%    	ps.delta(2)=ps.delta(1);
%    	ps.delta(3)=ps.delta(1);
%    end
%    if ps.xmin>ps.xmax || ps.ymin>ps.ymax || ps.zmin>ps.zmax 
%        error('min must be < max')
%    end
%    return

% elseif nargin()==8
%    ps.delta=varargin{1};
%    ps.xmin=varargin{2};
%    ps.xmax=varargin{3};
%    ps.ymin=varargin{4};
%    ps.ymax=varargin{5};
%    ps.zmin=varargin{6};
%    ps.zmax=varargin{7};
%    ps.tmin=0;
%    ps.tmax=0;
%	ps.deltat=0;
%    ps.vector_flag=-1;
%	ps.time_flag=1;
%    ps.vector=[];
%	ps.tvector=varargin{8};
%    ps.polar=-1;
%    ps.spherical=-1;
%    if ps.delta(1)<0
%        error('delta cannot be <0')
%    end
%    if length(ps.delta)==1
%    	ps.delta(2)=ps.delta(1);
%    	ps.delta(3)=ps.delta(1);
%    end
%    if ps.xmin>ps.xmax ||ps.ymin>ps.ymax ||ps.zmin>ps.zmax 
%        error('min must be < max')
%    end
%    return

% elseif nargin()==2
%    ps.delta(1:3)=0;
%    ps.xmin=0;
%    ps.xmax=0;
%    ps.ymin=0;
%    ps.ymax=0;
%    ps.zmin=0;
%    ps.zmax=0;
%    ps.tmin=0;
%    ps.tmax=0;
%    ps.vector_flag=1;
%	ps.time_flag=1;
%    ps.vector=varargin{1};
%	ps.tvector=varargin{2};
%    ps.polar=-1;
%    ps.spherical=-1;
    
% elseif nargin()==4
%    ps.delta(1:3)=0;
%    ps.xmin=0;
%    ps.xmax=0;
%    ps.ymin=0;
%    ps.ymax=0;
%    ps.zmin=0;
%    ps.zmax=0;
%    ps.tmin=varargin{2};
%    ps.tmax=varargin{3};
%	ps.deltat=varargin{4};
%    ps.vector_flag=1;
%	ps.time_flag= -1;
%    ps.vector=varargin{1};
%    ps.polar=-1;
%    ps.spherical=-1;
%end

%end
