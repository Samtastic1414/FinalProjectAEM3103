%	Example 1.3-1 Paper Airplane Flight Path
%	Copyright 2005 by Robert Stengel
%	August 23, 2005
clear
clc
N=100;
averageHeight=zeros(N+1);
averageRange=zeros(N+1);
averageTime=zeros(N+1);
	global CL CD S m g rho	
	S		=	0.017;			% Reference Area, m^2
	AR		=	0.86;			% Wing Aspect Ratio
	e		=	0.9;			% Oswald Efficiency Factor;
	m		=	0.003;			% Mass, kg
	g		=	9.8;			% Gravitational acceleration, m/s^2
	rho		=	1.225;			% Air density at Sea Level, kg/m^3	
	CLa		=	3.141592 * AR/(1 + sqrt(1 + (AR / 2)^2));
							% Lift-Coefficient Slope, per rad
	CDo		=	0.02;			% Zero-Lift Drag Coefficient
	epsilon	=	1 / (3.141592 * e * AR);% Induced Drag Factor	
	CL		=	sqrt(CDo / epsilon);	% CL for Maximum Lift/Drag Ratio
	CD		=	CDo + epsilon * CL^2;	% Corresponding CD
	LDmax	=	CL / CD;			% Maximum Lift/Drag Ratio
	Gam		=	-atan(1 / LDmax);	% Corresponding Flight Path Angle, rad
	V		=	sqrt(2 * m * g /(rho * S * (CL * cos(Gam) - CD * sin(Gam))));
							% Corresponding Velocity, m/s
	Alpha	=	CL / CLa;			% Corresponding Angle of Attack, rad
	
    % Varied Height and range

    IV=[2, 3.55, 7.5];
    IFPA=[-0.5, -.18, 0.4];

%	a) Equilibrium Glide at Maximum Lift/Drag Ratio
	H		=	2;			% Initial Height, m
	R		=	0;			% Initial Range, m
	to		=	0;			% Initial Time, sec
	tf		=	6;			% Final Time, sec
	tspan	=	[to:.06:tf];
	xo		=	[V;Gam;H;R];
	[ta,xa]	=	ode23('EqMotion',tspan,xo);


%   e) Changing Velocity

    xo		=	[IV(1);0;H;R];
	[te,xe]	=	ode23('EqMotion',tspan,xo);

    xo		=	[IV(2);0;H;R];
	[tf,xf]	=	ode23('EqMotion',tspan,xo);

    xo		=	[IV(3);0;H;R];
	[tg,xg]	=	ode23('EqMotion',tspan,xo);

%   e) Changing flight path angle

    xo		=	[V;IFPA(1);H;R];
	[th,xh]	=	ode23('EqMotion',tspan,xo);

    xo		=	[V;IFPA(2);H;R];
	[ti,xi]	=	ode23('EqMotion',tspan,xo);

    xo		=	[V;IFPA(3);H;R];
	[tj,xj]	=	ode23('EqMotion',tspan,xo);

% Make sure to change white to black before submit
% Plot the Max, Min, and Nominal Values for range vs height
    figure
    subplot(2,1,1)
    
	plot(xe(:,4),xe(:,3),'r',xf(:,4),xf(:,3),'k',xg(:,4),xg(:,3),'g')
	title("Time vs Height for diffrent Velocities"),xlabel('Range, m'), ylabel('Height, m'), grid

    subplot(2,1,2)
    
    plot(xh(:,4),xh(:,3),'r',xi(:,4),xi(:,3),'k',xj(:,4),xj(:,3),'g')
	title("Time vs Height for diffrent FPA"),xlabel('Range, m'), ylabel('Height, m'), grid

% Random Parameters Ranges

    vmin=IV(1); vmax=IV(3);

    fpamin=IFPA(1); fpamax=IFPA(3);

    Vrand=zeros(N)*nan;
    FPArand=zeros(N)*nan;
    color = ['r', 'g', 'b', 'k', 'y'];


    % Plots 100 diffrent flights
    figure
    hold on
    for i =1:N

        Vrand(i)=vmin + (vmax-vmin)*rand(1);
        FPArand(i)=fpamin + (fpamax-fpamin)*rand(1);

        xo		=	[Vrand(i);FPArand(i);H;R];

        [tfpar, xfpar] = ode23('EqMotion',tspan,xo);


        averageTime(1:length(tfpar),i)=averageTime(1:length(tfpar),i)/i+tfpar(:,1);
        averageHeight(1:length(xfpar),i)=averageHeight(1:length(xfpar),i)/i+xfpar(:,3);
        averageRange(1:length(xfpar),i)=averageRange(1:length(xfpar),i)/i+xfpar(:,4);

        plot(xfpar(:,4),xfpar(:,3),color(mod(i,5)+1));
    end
    title("Range vs Height for 100 Flights"), xlabel('Range, m'), ylabel('Height, m'), grid

    % Gets the average for time, range, and height in each row and puts
    % them in a N*3 matrix

        averageTime=sum(averageTime,2)/N;
        averageRange=sum(averageRange,2)/N;
        averageHeight=sum(averageHeight,2)/N;

        FlightPath=cat(2,averageTime,averageHeight,averageRange);

        % Plots the average flight
        plot(FlightPath(:,3),FlightPath(:,2),'*r')


    % Plots the Range/Height vs Time by finding ploynomial. It also finds the Dirivitevs
        figure 
        subplot(2,1,1)

        plot(FlightPath(:,1),FlightPath(:,2))
        p = polyfit(FlightPath(:,1),FlightPath(:,2),13);
        Height=polyval(p,tspan);
        plot(tspan,Height)

        title("Time vs Height"),xlabel('Time, s'), ylabel('Height, m'), grid

        subplot(2,1,2)
        plot(FlightPath(:,1),FlightPath(:,3))

        p = polyfit(FlightPath(:,1),FlightPath(:,3),13);
        Range=polyval(p,tspan);
        plot(tspan,Range)

        title("Time vs Range"),xlabel('Time, s'), ylabel('Range, m'), grid

        
% Take the dirivative of TvRange and TvHeight

        Rp_num=Num_Der_Cent(tspan,Range);
        figure
        subplot(2,1,1)

        plot(tspan,Rp_num)
        title("Time vs Range Prime"), xlabel('Time, s'), ylabel('Range Prime, m'), grid

        Hp_num=Num_Der_Cent(tspan,Height);

        subplot(2,1,2)
        plot(tspan,Hp_num)
        title("Time vs Height Prime"), xlabel('Time, s'), ylabel('Height Prime, m'), grid




