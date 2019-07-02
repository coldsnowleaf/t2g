%%************************************************************************
%% Plots anchor points, estimations of unknown points and actual locations
%% and the discrepancies between them
%% Blue Diamond : Anchor
%% Red Star : Estimated position of unknown point
%% Green Circle : Actual position of unknown point
%%
%% Input: 
%% P0: Anchor positions. If there is no anchor, input P0 = [];
%% PP: Actual positions of unknown points
%% X_opt: Estimated positions of unknown points
%% Plane 'xy','yz','xz' : Desired 2-D plane if points are 3-D
%%       'xyz'          : 3-D 
%%************************************************************************

   function plotpositionsaa(PP,Xopt,ConnectivityM,BoxScale,graphlabel);
   figure;
  imshow('floor2.png')
   hold on
   %axes('FontSize',18,'FontWeight','bold');
   markersize = 10; 
   PP=PP*BoxScale;
   Xopt=Xopt*BoxScale;
   dim = size(Xopt,1);
   plane = 'xy';
   if (dim == 2); plane = 'xy'; end
   if (dim == 3); plane = 'xyz'; end
%% 
   if strcmp(plane,'xy')
      if strcmp(plane,'xy')
         idx1 = 1; idx2 = 2; 
      elseif strcmp(plane,'xz')
         idx1 = 1; idx2 = 3;
      elseif strcmp(plane,'yz')
         idx1 = 2; idx2 = 3;
      end
      h=plot(Xopt(idx1,:),Xopt(idx2,:),'*r','markersize',15); 
      hold on; %grid on
      h=plot([Xopt(idx1,:); PP(idx1,:)],[Xopt(idx2,:); PP(idx2,:)],'b');
      set(h,'linewidth',2);
      h=plot(PP(idx1,:),PP(idx2,:),'og','markersize',markersize); 
      set(h,'linewidth',3);
      axis('square'); %axis(0.6*BoxScale*[-1,1,-1,1]);
      xlabel('X','FontSize',20),ylabel('Y','FontSize',20);
      %grid on;
      title(graphlabel);
      %axis([0,200,0,200])
      pause(0.1); hold off
   end
%%************************************************************************


