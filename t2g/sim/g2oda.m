function g2o_pos=g2oda(points,anchors,non_anchors,lneighbor,bneighbor,cneighbor,distMatrix,angleMatrix,ConnectivityM,enum,n)

npoints=size(points,1);
pos=zeros(npoints,2);
anum=size(anchors,2);%锚点数
nanum=size(non_anchors,2);%未定位节点数

%类三边测距法进行坐标初始化
 for i=1:anum
	temp_id=anchors(i);
 	pos(temp_id,:)=points(temp_id,:)+[0.05*randn(),0.05*randn()];
 end
 
 while(nanum>0)
     new_anchor=0;
     for i=1:nanum
        id=non_anchors(i);
        cnum=cneighbor(id,1);
        bnum=bneighbor(id,1);
        lnum=lneighbor(id,1);
        temp_c=intersect(cneighbor(id,2:cnum+1),anchors);
        temp_b=intersect(bneighbor(id,2:bnum+1),anchors);
        temp_l=intersect(lneighbor(id,2:lnum+1),anchors);
        if length(temp_c)>=1
            new_anchor=id;

            cid=temp_c(1);
            pos(id,:)=pos(cid,:)+[distMatrix(id,cid)*cos(angleMatrix(id,cid)),distMatrix(id,cid)*sin(angleMatrix(id,cid))];
            break;
        elseif length(temp_l)>=3
            new_anchor=id;
            
            syms x y eq1 eq2;
            x1=pos(temp_l(1),1);y1=pos(temp_l(1),2);d1=distMatrix(id,temp_l(1));
            x2=pos(temp_l(2),1);y2=pos(temp_l(2),2);d2=distMatrix(id,temp_l(2));
            x3=pos(temp_l(3),1);y3=pos(temp_l(3),2);d3=distMatrix(id,temp_l(3));
            eq1=(x-x1)^2+(y-y1)^2-d1^2;
            eq2=(x-x2)^2+(y-y2)^2-d2^2;
            [x,y]=solve(eq1,eq2,'x','y');
            x=vpa(x);y=vpa(y);
            delta1=abs((x(1)-x3)^2+(y(1)-y3)^2-d3^2);
            delta2=abs((x(2)-x3)^2+(y(2)-y3)^2-d3^2);
            if delta1>delta2
                pos(id,:)=[x(2),y(2)];%新节点定位
            else
                pos(id,:)=[x(1),y(1)];
            end
            break;
        elseif length(temp_b)>=2
            new_anchor=id;

            x1=pos(temp_b(1),1);y1=pos(temp_b(1),2);theta1=angleMatrix(id,temp_b(1));
            x2=pos(temp_b(2),1);y2=pos(temp_b(2),2);theta2=angleMatrix(id,temp_b(2));
            x=(y2-y1+x1*tan(theta1)-x2*tan(theta2))/(tan(theta1)-tan(theta2));
            y=y1-(x1-x)*tan(theta1);
            pos(id,:)=[x,y];%新节点定位
            break;
        elseif length(temp_b)>=1&&length(temp_l)>=2
            new_anchor=id;

            syms x y eq1 eq2;
            x1=pos(temp_l(1),1);y1=pos(temp_l(1),2);d1=distMatrix(id,temp_l(1));
            x2=pos(temp_l(2),1);y2=pos(temp_l(2),2);d2=distMatrix(id,temp_l(2));
            x3=pos(temp_b(1),1);y3=pos(temp_b(1),2);theta=angleMatrix(id,temp_b(1));
            eq1=(x-x1)^2+(y-y1)^2-d1^2;
            eq2=y-y3-(x-x3)*tan(theta);
            [x,y]=solve(eq1,eq2,'x','y');
            x=vpa(x);y=vpa(y);
            delta1=abs((x(1)-x2)^2+(y(1)-y2)^2-d2^2);
            delta2=abs((x(2)-x2)^2+(y(2)-y2)^2-d2^2);
            if delta1>delta2
                pos(id,:)=[x(2),y(2)];%新节点定位
            else
                pos(id,:)=[x(1),y(1)];
            end
            break;
        else
          continue;
        end
     end
     if new_anchor==0
         new_anchor=non_anchors(1);
         pos(new_anchor,:)=points(new_anchor,:)+[0.05*randn(),0.05*randn()];
     end
     anchors=[anchors,[new_anchor]];
     non_anchors(non_anchors==new_anchor)=[];
     non_anchors;
     nanum=nanum-1;
     anum=anum+1;
 end
 
%g2o优化
vmeans=zeros(2,npoints);
eids=zeros(2,enum);
emeans=zeros(2,enum);
etype=zeros(enum);
einfs=zeros(2,2,enum);
for j=1:npoints
    vmeans(:,j)=[pos(j,1),pos(j,2)];
end
vmeans;
count=1;
   for j=1:npoints
       for k=j+1:npoints  
           if ConnectivityM(j,k)==1
                etype(count)=1;
                eids(1,count)=j;
                eids(2,count)=k;
                
                emeans(:,count)=[distMatrix(j,k),0];
                
                einfs(1,1,count) = 20;
                einfs(2,1,count) = 0;
                einfs(1,2,count) = 0;
                einfs(2,2,count) = 1;

                
                count=count+1;
           elseif ConnectivityM(j,k)==2
                etype(count)=2;
                eids(1,count)=j;
                eids(2,count)=k;
                
                emeans(:,count)=[cos(angleMatrix(j,k)),sin(angleMatrix(j,k))];
                
                einfs(1,1,count) = 20;
                einfs(2,1,count) = 0;
                einfs(1,2,count) = 0;
                einfs(2,2,count) = 20;

                
                count=count+1;
           elseif ConnectivityM(j,k)==3
                etype(count)=3;
                eids(1,count)=j;
                eids(2,count)=k;
                
                emeans(:,count)=[distMatrix(j,k)*cos(angleMatrix(j,k)),distMatrix(j,k)*sin(angleMatrix(j,k))];
                
                einfs(1,1,count) = 400;
                einfs(2,1,count) = 0;
                einfs(1,2,count) = 0;
                einfs(2,2,count) = 400;

                
                count=count+1;
           end
       end
   end
size(eids)
temp_pos=ls_slam(vmeans, eids, emeans, einfs,etype, n);
g2o_pos=zeros(npoints,2);
   
   for j=1:npoints
       g2o_pos(j,:)=[temp_pos(1,j),temp_pos(2,j)];
   end

end