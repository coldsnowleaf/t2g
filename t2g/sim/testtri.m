global FPErrorArray;
global G2OErrorArray;
global FPMeanArray;
global G2OMeanArray;
load testedgefilterplusr.mat  
distMatrix=zeros(nodelength, nodelength);
angleMatrix=zeros(nodelength,nodelength);
for i = 1 : nodelength
    for j = 1 : nodelength
        if length(edgematrix(i,j).lengtharray) >= 1
            distMatrix(i,j) = norm( edgematrix(i,j).measureavg, 2);
            angleMatrix(i,j) = atan(edgematrix(i,j).measureavg(2)/ edgematrix(i,j).measureavg(1));
            if edgematrix(i,j).measureavg(1)<0
                angleMatrix(i,j)=angleMatrix(i,j)+pi;
            end
        end
    end
end

            

randp = randperm(nodelength);
anchors=randp(1:10);%锚点
non_anchors=randp(11:nodelength);%待定位节点

bneighbor=zeros(nodelength,nodelength);
cneighbor=zeros(nodelength,nodelength);
lneighbor=zeros(nodelength,nodelength);
enum=0;

for i=1:nodelength
    cnum=0;
    lnum=0;
    bnum=0;
    for j=1:nodelength
        if ConnectivityM(i,j)==1
            lnum=lnum+1;
            lneighbor(i,lnum+1)=j;
        elseif ConnectivityM(i,j)==2
            bnum=bnum+1;
            bneighbor(i,bnum+1)=j;
        elseif ConnectivityM(i,j)==3
            cnum=cnum+1;
            cneighbor(i,cnum+1)=j;
        end
    end
    lneighbor(i,1)=lnum;
    bneighbor(i,1)=bnum;
    cneighbor(i,1)=cnum;
end
enum=(sum(lneighbor(:,1))+sum(bneighbor(:,1))+sum(cneighbor(:,1)))/2
[tri_pos]=g2oda(pointpos',anchors,non_anchors,lneighbor,bneighbor,cneighbor,distMatrix,angleMatrix,ConnectivityM,enum,0);

[D,Z,T]=procrustes(pointpos', tri_pos, 'Scaling', false);
registg2oPos1=Z;
plotgraph([],pointpos,ConnectivityM);
tic 
plotgraph([],tri_pos',ConnectivityM);
plotpositionsaa (pointpos,registg2oPos1',ConnectivityM,1,'Trilateration');
save testtri.mat